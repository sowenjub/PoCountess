//
//  Domain.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import Foundation
import CoreData
import SwiftUI

extension Domain: Comparable {
    public static func < (lhs: Domain, rhs: Domain) -> Bool {
        lhs.position < rhs.position
    }

    var allCounters: [Counter] {
        let keys: [Counter] = (counters?.allObjects as? [Counter]) ?? []
        return keys.sorted()
    }
    
    var namespaceOrBlank: String {
        get { namespace ?? "" }
        set { self.namespace = newValue.isEmpty ? nil : newValue }
    }
    
    var titleOrBlank: String {
        get { title ?? "" }
        set { self.title = newValue.isEmpty ? nil : newValue }
    }
}
