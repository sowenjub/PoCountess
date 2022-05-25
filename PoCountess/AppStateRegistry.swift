//
//  AppStateRegistry.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 24/05/2022.
//

import Foundation

class AppStateRegistry: ObservableObject {
    var domainCoordinator = DomainCoordinator()
    var counterCoordinator = CounterCoordinator()
}

class DomainCoordinator: ObservableObject {
    @Published var selected: Domain?
    @Published var justAdded: Domain?
}

class CounterCoordinator: ObservableObject {
    @Published var justAdded: Counter?
}
