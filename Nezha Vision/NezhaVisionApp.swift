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
        
        WindowGroup("Pin View", id: "server-pin-view", for: GetServerDetailResponse.Server.ID.self) { $serverID in
            ServerPinView(dashboardViewModel: dashboardViewModel, serverID: serverID)
                .frame(minWidth: 400, minHeight: 300)
        }
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: ["server-pin"])
        
        WindowGroup("Server Details", id: "server-detail-view", for: GetServerDetailResponse.Server.ID.self) { $serverID in
            if let serverID {
                ServerDetailView(dashboardViewModel: dashboardViewModel, serverID: serverID)
            }
        }
        .defaultSize(width: 800, height: 700)
    }
}
