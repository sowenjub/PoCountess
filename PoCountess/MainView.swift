//
//  MainView.swift
//  Shared
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import SwiftUI
import CoreData

struct MainView: View {
    var body: some View {
        NavigationView {
            DomainsList()
            
            WelcomeView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
