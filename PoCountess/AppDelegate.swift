//
//  AppDelegate.swift
//  PoCountess (macOS)
//
//  Created by Arnaud Joubay on 25/05/2022.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    let persistenceController = PersistenceController.shared
    
    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "person.2.wave.2.fill", accessibilityDescription: "Chart Line")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 300, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(
            rootView: BarCountersList().environment(\.managedObjectContext, persistenceController.container.viewContext)
        )
    }
    
    @objc func togglePopover() {
        
//        Task {
//            await self.stockListVM.populateStocks()
//        }
        
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        
    }
    
}
