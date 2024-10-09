//
//  NezhaDesktopApp.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI
import NezhaMobileData

@main
struct NezhaDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Bindable var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @AppStorage("NMMenuBarEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var menuBarEnabled: Bool = true
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMLastModifyDate": 0,
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMMacPushNotificationsToken": ""
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup("Nezha Desktop", id: "main-view") {
            ContentView(dashboardViewModel: dashboardViewModel)
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        .defaultSize(width: 1000, height: 500)
        .commands {
            CommandGroup(before: CommandGroupPlacement.help) {
                Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                NavigationLink(destination: {
                    AcknowledgmentView()
                }) {
                    Text("Acknowledgments")
                }
            }
        }
        
        WindowGroup("Map View", id: "map-view") {
            ServerMapView(servers: dashboardViewModel.servers)
        }
        
        WindowGroup("Server Details", id: "server-detail-view", for: Server.ID.self) { $serverID in
            if let serverID {
                ServerDetailView(dashboardViewModel: dashboardViewModel, serverID: serverID)
            }
        }
        .defaultSize(width: 800, height: 700)
        .commandsRemoved()
        
        Settings {
            SettingView(dashboardViewModel: dashboardViewModel)
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
        }
        
        WindowGroup("Alert Details", id: "alert-detail-view", for: ServerAlert.ID.self) { $alertID in
            if let alertID {
                AlertDetailView(alertID: alertID)
            }
            else {
                if let notificationData = appDelegate.notificationState.notificationData {
                    AlertDetailView(time: nil, title: notificationData.title, content: notificationData.body)
                }
                else {
                    ContentUnavailableView("No alert information", systemImage: "exclamationmark.bubble")
                }
            }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        .defaultSize(width: 600, height: 600)
        .commandsRemoved()
        .handlesExternalEvents(matching: Set(arrayLiteral: "alert-details"))
        
        MenuBarExtra(isInserted: $menuBarEnabled) {
            MenuBarView(dashboardViewModel: dashboardViewModel)
        } label: {
            Image(systemName: "server.rack")
        }
        .menuBarExtraStyle(.window)
    }
}
