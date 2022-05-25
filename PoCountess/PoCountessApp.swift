//
//  PoCountessApp.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

@main
struct PoCountessApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
