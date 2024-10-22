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
    init() {
        NMCore.registerUserDefaults()
    }
    
    var body: some Scene {
        WindowGroup("Nezha Vision", id: "main-view") {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .onAppear {
                    NMCore.syncWithiCloud()
                }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
    }
}
