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
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @AppStorage("NMMenuBarEnabled", store: NMCore.userDefaults) var menuBarEnabled: Bool = true
    
    init() {
        NMCore.registerUserDefaults()
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
                Link("User Guide", destination: NMCore.userGuideURL)
                NavigationLink(destination: {
                    NMUI.AcknowledgmentView()
                }) {
                    Text("Acknowledgments")
                }
            }
        }
        
        WindowGroup("Map View", id: "map-view") {
            ServerMapView(servers: dashboardViewModel.servers)
        }
        
        WindowGroup("Server Details", id: "server-detail-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerDetailView(dashboardViewModel: dashboardViewModel, id: id)
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
                .onAppear {
                    if dashboardLink != "" && dashboardUsername != "" && !dashboardViewModel.isMonitoringEnabled {
                        dashboardViewModel.startMonitoring()
                    }
                }
        } label: {
            Image(systemName: "server.rack")
        }
        .menuBarExtraStyle(.window)
    }
}
