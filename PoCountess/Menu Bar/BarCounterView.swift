//
//  BarCounterView.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

struct BarCounterView: View {
    @ObservedObject var counter: Counter
    @StateObject private var countRequest: CountAPIKey
    
    @State private var isShowingErrorPopover = false
    @State private var isShowingTitle = false
    
    internal init(_ counter: Counter) {
        self.counter = counter
        self._countRequest = StateObject(wrappedValue: CountAPIKey(counter))
    }
    
    func stringValue(_ value: Int64?) -> String {
        guard let value = value else { return "" }
        return "\(value)"
    }
    
    var isUnknownKey: Bool {
        if counter.key == nil { return true }
        switch countRequest.error {
            case .statusCode(let code): return code == 404
            default: return false
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(counter.key ?? "new.key")
                    .accessibilityLabel("counter.key.label")
                    .font(counter.titleOrBlank.isEmpty ? .headline : .footnote)
                    .foregroundColor(counter.titleOrBlank.isEmpty && counter.key != nil ? .primary : .secondary)
                if !counter.titleOrBlank.isEmpty {
                    Text(counter.titleOrBlank)
                        .accessibilityLabel("counter.title.label")
                        .font(.headline)
                }
            }
            Spacer()
            HStack(alignment: .center) {
                if let error = countRequest.error {
                    Button {
                        isShowingErrorPopover.toggle()
                    } label: {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .help(error.localizedDescription)
                            .popover(isPresented: $isShowingErrorPopover, arrowEdge: .leading) {
                                Text(error.localizedDescription)
                                    .padding()
                                    .font(.footnote)
                            }
                    }
                    .accessibilityHint("counter.error.hint")
                    .buttonStyle(.plain)
                } else {
                    Text(stringValue(countRequest.value))
                        .accessibilityLabel("counter.value.label")
                        .font(.system(.title, design: .rounded).weight(.black).monospacedDigit())
                        .overlay(
                            Group {
                                if countRequest.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.5)
                                }
                            }
                        )
                }
            }
        }
        .padding(8)
        .task {
            await countRequest.get()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshAllCounters)) { _ in
            Task { await countRequest.get() }
        }
    }
}
