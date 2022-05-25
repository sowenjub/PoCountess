//
//  CounterRow.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 23/05/2022.
//

import SwiftUI

struct CounterRow: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var counter: Counter
    
    @Binding var selected: Counter?
    @Binding var editing: Counter?
    
    internal init(_ counter: Counter, selected: Binding<Counter?>, editing: Binding<Counter?>) {
        self.counter = counter
        self._selected = selected
        self._editing = editing
    }

    var body: some View {
        if editing == counter {
            CounterForm(counter)
        } else {
            CounterView(counter)
                .listRowBackground((selected == counter ? Color.accentColor.opacity(0.15) : .clear).clipped().cornerRadius(8))
                .contentShape(Rectangle())
                .contextMenu {
                   Button {
                       deleteCounter(counter)
                   } label: {
                       Text("Delete")
                   }
                   .keyboardShortcut(.delete)
                }
        }
    }
    
    private func deleteCounter(_ counter: Counter) {
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
}

struct CounterRow_Previews: PreviewProvider {
    static var previewCounter: Counter {
        let counter = Counter(context: PersistenceController.preview.container.viewContext)
        counter.key = "toBeCounted"
        return counter
    }
    
    static var previews: some View {
        CounterRow(previewCounter, selected: .constant(nil), editing: .constant(nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(maxWidth: 400, minHeight: 50)
    }
}
