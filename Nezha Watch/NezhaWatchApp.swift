//
//  NezhaWatchApp.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

@main
struct NezhaWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMLastModifyDate": 0,
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMPushNotificationsToken": "",
                "NMPushToStartToken": "",
                "NMWatchPushNotificationsToken": "",
                "NMWatchLastViewedServerID": 0
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
