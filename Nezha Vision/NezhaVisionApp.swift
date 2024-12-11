//
//  Nezha_VisionApp.swift
//  Nezha Vision
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI
import NezhaMobileData

@main
struct NezhaVisionApp: App {
    var dashboardViewModel: DashboardViewModel = .init()
    var serverGroupViewModel: ServerGroupViewModel = .init()
    var serviceViewModel: ServiceViewModel = .init()
    var notificationViewModel: NotificationViewModel = .init()
    
    init() {
        NMCore.registerUserDefaults()
    }
    
    var body: some Scene {
        WindowGroup("Nezha Vision", id: "main-view") {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environment(dashboardViewModel)
                .environment(serverGroupViewModel)
                .environment(serviceViewModel)
                .environment(notificationViewModel)
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        
        WindowGroup("Pin View", id: "server-pin-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerPinView(id: id)
                    .frame(width: 400, height: 300)
                    .environment(dashboardViewModel)
                    .handlesExternalEvents(preferring: [], allowing: [])
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup("Server Details", id: "server-detail-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerDetailView(id: id)
                    .environment(dashboardViewModel)
                    .handlesExternalEvents(preferring: [], allowing: [])
            }
        }
        .defaultSize(width: 800, height: 700)
    }
}
