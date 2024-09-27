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
    var themeStore: ThemeStore = ThemeStore()
    var tabBarState: TabBarState = TabBarState()
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMLastModifyDate": 0,
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMDashboardGRPCLink": "",
                "NMDashboardGRPCPort": "",
                "NMAgentSecret": "",
                "NMPushNotificationsToken": "",
                "NMPushToStartToken": "",
                "NMWatchPushNotificationsToken": ""
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environmentObject(appDelegate.notificationState)
                .environment(themeStore)
                .environment(tabBarState)
                .onAppear {
                    appDelegate.tabBarState = tabBarState
                    syncWithiCloud()
                }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
    }
}
