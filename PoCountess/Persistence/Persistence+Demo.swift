//
//  Persistence+Demo.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 24/05/2022.
//

import CoreData

extension PersistenceController {
    static func loadDemo(context: NSManagedObjectContext) throws -> Domain {
        let newDomain = Domain(context: context)
        newDomain.title = "🏰 County"
        newDomain.namespace = "app.countess.county"
        
        let counters = [
            Counter("test", name: "🏹 First tries", context: context),
            Counter("test-again", name: "🎯 Second tries", context: context),
            Counter("untitled-counters", context: context),
            Counter("keys Repared", name: "🗝 Keys Repared", context: context),
            Counter("purchases", name: "⚜️ Gold stashed", protected: true, context: context),
            Counter("bugsSpotted", name: "🐛 Bugs spotted", context: context),
            Counter("engravings", name: "🪨 \"X was here\" engravings", context: context),
        ]
        counters.reversed().enumerated().forEach { idx, counter in
            counter.position = Int16(idx)
            newDomain.addToCounters(counter)
        }
        
        return newDomain
    }
}
