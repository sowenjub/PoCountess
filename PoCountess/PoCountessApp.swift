//
//  PoCountessApp.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

@main
struct PoCountessApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    let appStateRegistry = AppStateRegistry()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appStateRegistry)
                .environmentObject(appStateRegistry.domainCoordinator)
                .environmentObject(appStateRegistry.counterCoordinator)
        }.commands {
            SidebarCommands()
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Divider()
                Button("New Domain") {
                    addDomain()
                }.keyboardShortcut("d", modifiers: [.command])
                Button("New Counter") {
                    addCounter()
                }.keyboardShortcut("k", modifiers: [.command])
            }
            CommandMenu("Counters") {
                Button {
                    NotificationCenter.default.post(name: .refreshAllCounters, object: nil)
                } label: {
                    Text("counters.refresh")
                }
                .keyboardShortcut("r", modifiers: [.command])

                Divider()
            }
        }
    }
    
    private func addDomain() {
        let viewContext = persistenceController.container.viewContext
        withAnimation {
            let newDomain = Domain(context: viewContext)
            let maxRequest = Domain.fetchRequest()
            maxRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Domain.position, ascending: false)]
            maxRequest.fetchLimit = 1
            do {
                if let topDomain = (try viewContext.fetch(maxRequest) as [Domain]).first {
                    newDomain.position = topDomain.position + 1
                }
                try viewContext.save()
                appStateRegistry.domainCoordinator.selected = newDomain
                appStateRegistry.domainCoordinator.justAdded = newDomain
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addCounter() {
        let viewContext = persistenceController.container.viewContext
        guard let domain = appStateRegistry.domainCoordinator.selected else {
            return
        }
        let newCounter = Counter(context: viewContext)
        if let topCounter = domain.allCounters.sorted().last {
            newCounter.position = topCounter.position + 1
        }
        domain.addToCounters(newCounter)

        withAnimation {
            do {
                try viewContext.save()
                appStateRegistry.counterCoordinator.justAdded = newCounter
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
