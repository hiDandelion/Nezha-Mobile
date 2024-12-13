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
    var dashboardViewModel: DashboardViewModel = .init()
    var serverGroupViewModel: ServerGroupViewModel = .init()
    var serviceViewModel: ServiceViewModel = .init()
    var notificationViewModel: NotificationViewModel = .init()
    @AppStorage("NMMenuBarEnabled", store: NMCore.userDefaults) var menuBarEnabled: Bool = true
    
    init() {
        NMCore.registerUserDefaults()
    }
    
    var body: some Scene {
        Window("Nezha Desktop", id: "main-view") {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environment(dashboardViewModel)
                .environment(serverGroupViewModel)
                .environment(serviceViewModel)
                .environment(notificationViewModel)
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        .defaultSize(width: 1000, height: 500)
        .commands {
            CommandGroup(before: CommandGroupPlacement.help) {
                Link("User Guide", destination: NMCore.userGuideURL)
                NavigationLink(destination: {
                    NMUI.AcknowledgmentView()
                }) {
                    Text("Acknowledgments")
                }
            }
        }
        
        Window("Map View", id: "map-view") {
            ServerMapView()
                .environment(dashboardViewModel)
        }
        
        WindowGroup("Server Details", id: "server-detail-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerDetailView(id: id)
                    .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                    .environment(dashboardViewModel)
            }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        .defaultSize(width: 800, height: 700)
        .commandsRemoved()
        
        WindowGroup("Alert Details", id: "alert-detail-view") {
            if let notificationData = appDelegate.notificationState.notificationData {
                AlertDetailView(time: nil, title: notificationData.title, content: notificationData.body)
            }
            else {
                ContentUnavailableView("No alert information", systemImage: "exclamationmark.bubble")
            }
        }
        .defaultSize(width: 600, height: 600)
        .commandsRemoved()
        .handlesExternalEvents(matching: Set(arrayLiteral: "alert-details"))
        
        MenuBarExtra(isInserted: $menuBarEnabled) {
            MenuBarView()
                .environment(dashboardViewModel)
        } label: {
            Image(systemName: "server.rack")
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environment(dashboardViewModel)
        }
    }
}
