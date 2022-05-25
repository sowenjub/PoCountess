//
//  CountersList.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import SwiftUI

extension NSNotification.Name {
    static let refreshAllCounters = Notification.Name("refreshAllCounters")
}

struct CountersList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var counterCoordinator: CounterCoordinator

    @ObservedObject var domain: Domain

    @FetchRequest
    private var counters: FetchedResults<Counter>
    
    @State var selection: Set<Counter> = []
    @State private var selectedCounter: Counter? = nil
    @State private var editingCounter: Counter? = nil

    internal init(_ domain: Domain) {
        self.domain = domain
        self._counters = FetchRequest<Counter>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Counter.position, ascending: false)],
            predicate: NSPredicate(format: "%K == %@", #keyPath(Counter.domain), domain),
            animation: .default)
    }
    
    var body: some View {
        VStack {
            DomainForm(domain)

            List(selection: $selection) {
                ForEach(counters) { counter in
                    let selectGesture = TapGesture().onEnded {
                        editingCounter = nil
                        selectedCounter = counter
                    }
                    let editGesture = TapGesture(count: 2).onEnded {
                        editingCounter = counter
                    }
                    CounterRow(counter, selected: $selectedCounter, editing: $editingCounter)
                        .gesture(selectGesture.simultaneously(with: editGesture))
                        .keyboardShortcut(.return)
                        .onSubmit {
                            saveChanges()
                            editingCounter = nil
                        }
                }
                .onDelete(perform: deleteCounters)
            }
            .onDeleteCommand {
                if let counter = selectedCounter {
                    deleteCounter(counter)
                }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                if !counters.isEmpty {
                    Button(action: refreshCountersValues) {
                        Label("counters.refresh", systemImage: "arrow.clockwise")
                    }
                    .keyboardShortcut("r", modifiers: [.command])
                }
            }
            ToolbarItem {
                Button(action: addCounter) {
                    Label("counter.add", systemImage: "plus")
                }
            }
        }
        .onChange(of: counterCoordinator.justAdded) { newCounter in
            guard newCounter != nil else { return }
            selectedCounter = newCounter
            editingCounter = newCounter
        }
    }
    
    private func addCounter() {
        let newCounter = Counter(context: viewContext)
        if let topCounter = domain.allCounters.sorted().last {
            newCounter.position = topCounter.position + 1
        }
        domain.addToCounters(newCounter)
        withAnimation {
            do {
                selectedCounter = newCounter
                editingCounter = newCounter
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteCounter(_ counter: Counter) {
        withAnimation {
            viewContext.delete(counter)
            
            if selectedCounter == counter {
                selectedCounter = nil
            }

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
    
    private func deleteCounters(offsets: IndexSet) {
        withAnimation {
            // FUTURE
            // https://developer.apple.com/forums/thread/668299
            viewContext.perform {
                let deletedCounters = offsets.map { counters[$0] }
                deletedCounters.forEach(viewContext.delete)
                
                var deleteSelectedCounter = false
                if let selectedCounter = selectedCounter,
                   deletedCounters.contains(selectedCounter) {
                    deleteSelectedCounter = true
                }

                do {
                    try viewContext.save()
                    if deleteSelectedCounter {
                        selectedCounter = nil
                    }
                } catch {
                    viewContext.rollback()
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    func saveChanges() {
        do {
            try viewContext.saveIfChanges()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func refreshCountersValues() {
        NotificationCenter.default.post(name: .refreshAllCounters, object: nil)
    }
}

struct CountersList_Previews: PreviewProvider {
    static var previewDomain: Domain {
        let domain = Domain(context: PersistenceController.preview.container.viewContext)
        domain.namespace = "app.countess.preview"
        return domain
    }
    
    static var previews: some View {
        CountersList(previewDomain)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
    
