//
//  DomainsList.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 24/05/2022.
//

import SwiftUI

struct DomainsList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var domainCoordinator: DomainCoordinator

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Domain.position, ascending: false)],
        animation: .default)
    private var domains: FetchedResults<Domain>

    var body: some View {
        List {
            ForEach(domains) { domain in
                NavigationLink(tag: domain, selection: $domainCoordinator.selected) {
                    DomainRow(domain)
                } label: {
                    Text(domain.title ?? domain.namespace ?? "new.domain")
                        .foregroundColor(domain.namespace == nil ? .secondary : .primary)
                }
                .contextMenu {
                   Button {
                       deleteDomain(domain)
                   } label: {
                       Text("Delete")
                   }
                   .keyboardShortcut(.delete)
                }
            }
            .onDelete(perform: deleteDomains)
        }
        .listStyle(.sidebar)
        .onDeleteCommand {
            if let domain = domainCoordinator.selected {
                deleteDomain(domain)
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                        .help("Toggle Sidebar")
                }
            }
            ToolbarItem {
                Spacer() // A simple spacer won't do
            }
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addDomain) {
                    Label("domain.add", systemImage: "plus")
                }
            }
        }
        .onAppear {
            domainCoordinator.selected = domains.first
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func addDomain() {
        withAnimation {
            let newDomain = Domain(context: viewContext)
            newDomain.position = (domains.first?.position ?? 0) + 1
            do {
                try viewContext.save()
                domainCoordinator.selected = newDomain
                domainCoordinator.justAdded = newDomain
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteDomain(_ domain: Domain) {
        withAnimation {
            viewContext.delete(domain)
            if domain == domainCoordinator.selected {
                domainCoordinator.selected = domains.filter({ $0 != domain }).first
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

    private func deleteDomains(offsets: IndexSet) {
        withAnimation {
            let deletedDomains = offsets.map { domains[$0] }
            deletedDomains.forEach(viewContext.delete)
            
            var deleteSelectedDomain = false
            if let selectedDomain = domainCoordinator.selected,
               deletedDomains.contains(selectedDomain) {
                deleteSelectedDomain = true
            }

            do {
                try viewContext.save()
                if deleteSelectedDomain {
                    domainCoordinator.selected = domains.first
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

struct DomainListView_Previews: PreviewProvider {
    static var previews: some View {
        DomainsList()
    }
}
