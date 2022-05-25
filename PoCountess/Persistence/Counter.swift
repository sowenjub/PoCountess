//
//  Counter.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import Foundation
import CoreData

extension Counter: Comparable {
    public static func < (lhs: Counter, rhs: Counter) -> Bool {
        lhs.position < rhs.position
    }
    
    var keyOrBlank: String {
        get { key ?? "" }
        set { self.key = newValue.isEmpty ? nil : newValue }
    }
    
    var titleOrBlank: String {
        get { title ?? "" }
        set { self.title = newValue.isEmpty ? nil : newValue }
    }
    
    convenience init(_ key: String, name: String? = nil, position: Int16 = 0, protected: Bool = true, context: NSManagedObjectContext) {
        self.init(context: context)
        self.key = key
        self.title = name
        self.position = position
        self.isProtected = protected
    }
}
