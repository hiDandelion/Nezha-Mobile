//
//  Nezha_MobileApp.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import NezhaMobileData

@main
struct NezhaMobileApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var theme: NMTheme = .init()
    
    init() {
        NMCore.registerUserDefaults()
        NMCore.registerKeychain()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environment(appDelegate.state)
                .environment(theme)
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
    }
}
