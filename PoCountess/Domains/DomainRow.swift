//
//  DomainRow.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 24/05/2022.
//

import SwiftUI

// An intermediary view to handle deletion gracefull and display the WelcomeView
struct DomainRow: View {
    @ObservedObject var domain: Domain

    /*
     Initially, I used domain.isDeleted and not .onReceive.
     But this would cause a stranger behavior: display the WelcomeView() when the last but one entry is deleted, and then display a ghost CountersList when the last one is deleted.
     */
    @State private var isDeleted = false

    internal init(_ domain: Domain) {
        self.domain = domain
    }

    var body: some View {
        if isDeleted {
            WelcomeView()
        } else {
            CountersList(domain)
                .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave), perform: { notification in
                    guard let userInfo = notification.userInfo,
                          let deletedEntities = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
                          deletedEntities.contains(domain)
                    else {
                        return
                    }
                    isDeleted = true
                })
        }
    }
}

struct DomainWrapper_Previews: PreviewProvider {
    static var previewDomain: Domain {
        let domain = Domain(context: PersistenceController.preview.container.viewContext)
        domain.namespace = "app.countess.preview"
        return domain
    }
    
    static var previews: some View {
        DomainRow(previewDomain)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
