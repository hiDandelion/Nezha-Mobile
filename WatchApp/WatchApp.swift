//
//  Watch_AppApp.swift
//  Watch App Watch App
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

@main
struct WatchApp: App {
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMLastModifyDate": 0
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
