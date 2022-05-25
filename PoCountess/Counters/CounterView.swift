//
//  CounterView.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import SwiftUI

struct CounterView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var counter: Counter
    @StateObject private var countRequest: CountAPIKey
    
    @State private var isShowingErrorPopover = false
    @State private var isShowingTitle = false
    
    internal init(_ counter: Counter) {
        self.counter = counter
        self._countRequest = StateObject(wrappedValue: CountAPIKey(counter))
    }
    
    func saveChanges() {
        viewContext.perform {
            do {
                try viewContext.saveIfChanges()
                Task { await countRequest.get() }
            } catch let error {
                print(error.localizedDescription)
            }
        }
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
                if countRequest.value != nil {
                    Button(action: toggleCounterProtection) {
                        Image(systemName: counter.isProtected ? "lock.fill" : "lock.open")
                    }
                    .accessibilityHint("counter.hit.hint")
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)

                    Button {
                        Task { await countRequest.hit() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityHint("counter.hit.hint")
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .disabled(counter.isProtected)
                }
                if isUnknownKey && countRequest.validate() {
                    Button("counter.create") {
                        Task { await countRequest.create() }
                    }
                    .accessibilityHint("counter.create.hint")
                } else if let error = countRequest.error {
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
    
    func deleteKey() {
        withAnimation {
            viewContext.delete(counter)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func toggleCounterProtection() {
        withAnimation {
            counter.isProtected.toggle()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previewCounter: Counter {
        let counter = Counter(context: PersistenceController.preview.container.viewContext)
        counter.key = "toBeCounted"
        return counter
    }
    
    static var previews: some View {
        CounterView(previewCounter)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(maxWidth: 400, minHeight: 50)
    }
}
