//
//  NezhaDesktopApp.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

@main
struct NezhaDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Bindable var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMLastModifyDate": 0
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dashboardViewModel: dashboardViewModel)
        }
        .defaultSize(width: 1000, height: 500)
        .commands {
            CommandGroup(before: CommandGroupPlacement.help) {
                Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                NavigationLink(destination: {
                    AboutView()
                }) {
                    Text("About")
                }
            }
        }
        
        WindowGroup("Map View", id: "map-view") {
            ServerMapView(servers: dashboardViewModel.servers)
        }
        
        WindowGroup("Server Details", for: Server.ID.self) { $serverID in
            if let serverID {
                ServerDetailView(dashboardViewModel: dashboardViewModel, serverID: serverID)
            }
        }
        .defaultSize(width: 800, height: 700)
        .commandsRemoved()
        
        Settings {
            SettingView(dashboardViewModel: dashboardViewModel)
        }
    }
}
