//
//  AppDelegate.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/5/24.
//

import SwiftUI

class AppDelegate: NSObject,ObservableObject,NSApplicationDelegate{
    @Bindable var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    
    @Published var statusItem: NSStatusItem?
    @Published var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }
    
    func setupMenuBar(){
        // Popover Properties
        popover.animates = true
        popover.behavior = .transient
        
        // Linking SwiftUI View
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: MenuBarView(dashboardViewModel: dashboardViewModel))
        
        // Making it as Key Window
        popover.contentViewController?.view.window?.makeKey()
        
        // Setting Menu Bar Icon and Action
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let menuButton = statusItem?.button{
            menuButton.image = .init(systemSymbolName: "server.rack", accessibilityDescription: nil)
            menuButton.action = #selector(menuButtonAction(sender:))
        }
    }
    
    @objc func menuButtonAction(sender: AnyObject){
        // Showing/Closing Popover
        if popover.isShown{
            popover.performClose(sender)
        }
        else{
            if let menuButton = statusItem?.button{
                popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
            }
        }
    }
}
