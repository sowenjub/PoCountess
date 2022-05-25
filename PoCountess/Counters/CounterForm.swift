//
//  CounterForm.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 22/05/2022.
//

import SwiftUI

struct CounterForm: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var counter: Counter
    @StateObject private var countRequest: CountAPIKey
    
    @State private var isShowingExpirePopover = false

    @FocusState private var isFormFocused: Bool
    
    enum FocusField: Hashable {
        case title, name
    }
    @FocusState private var focusedField: FocusField?
    
    internal init(_ counter: Counter) {
        self.counter = counter
        self._countRequest = StateObject(wrappedValue: CountAPIKey(counter))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                TextField("Key", text: $counter.keyOrBlank, prompt: Text("new.key"))
                    .accessibilityLabel("counter.key.label")
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .name)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextField("Title", text: $counter.titleOrBlank, prompt: Text("Human name"))
                    .accessibilityLabel("counter.title.label")
                    .focused($focusedField, equals: .title)
                    .font(.headline)
                    .tint(.yellow)
            }
            .textFieldStyle(.plain)
            if let info = countRequest.info {
                Spacer()
                HStack(alignment: .top) {
                    Button {
                        counter.isProtected.toggle()
                    } label: {
                        Label {
                            Text(LocalizedStringKey(stringLiteral: "counter.protected.button.\(counter.isProtected ? "true" : "false")"))
                        } icon: {
                            Image(systemName: counter.isProtected ? "lock.fill" : "lock.open")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .accessibilityHint("counter.hit.hint")
                    .buttonStyle(.plain)
                    Spacer()
                    Label {
                        Text(
                            info.createdAt.formatted(
                                .dateTime
                                    .year().month().day()
                                    .hour().minute().second()
                            )
                        )
                    } icon: {
                        Image(systemName: "calendar")
                    }

                    Button {
                        isShowingExpirePopover = true
                    } label: {
                        Label("Expires in \(info.daysToLive) days", systemImage: "hourglass")
                            .help("counter.ttl.about")
                            .popover(isPresented: $isShowingExpirePopover, arrowEdge: .leading) {
                                Text("counter.ttl.about")
                                    .padding()
                                    .font(.footnote)
                            }
                    }
                    .accessibilityHint("counter.error.hint")
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.15))
        )
        .onAppear {
            focusedField = counter.title == nil ? .name : .title
        }
        .task {
            await countRequest.info()
        }
        .textFieldStyle(.plain)
        .labelsHidden()
    }
}

struct CounterForm_Previews: PreviewProvider {
    static var previewCounter: Counter {
        let counter = Counter(context: PersistenceController.preview.container.viewContext)
        counter.key = "toBeCounted"
        return counter
    }
    
    static var previews: some View {
        CounterForm(previewCounter)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
