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
    @Bindable var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    
    init() {
        NMCore.registerUserDefaults()
    }
    
    var body: some Scene {
        WindowGroup("Nezha Vision", id: "main-view") {
            ContentView(dashboardViewModel: dashboardViewModel)
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .onAppear {
                    NMCore.syncWithiCloud()
                }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
        
        WindowGroup("Pin View", id: "server-pin-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerPinView(id: id, dashboardViewModel: dashboardViewModel)
                    .frame(width: 400, height: 300)
                    .handlesExternalEvents(preferring: [], allowing: [])
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup("Server Details", id: "server-detail-view", for: ServerData.ID.self) { $id in
            if let id {
                ServerDetailView(id: id, dashboardViewModel: dashboardViewModel)
                    .handlesExternalEvents(preferring: [], allowing: [])
            }
        }
        .defaultSize(width: 800, height: 700)
    }
}
