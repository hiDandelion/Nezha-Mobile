//
//  NMCore.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import Foundation
import SwiftUI
#if os(iOS) || os(watchOS) || os(visionOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

class NMCore {
    static let userGuideURL: URL = URL(string: "https://support.argsment.com/nezha-mobile/user-guide")!
    static let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    
    static func registerUserDefaults() {
        let defaultValues: [String: Any] = [
            "NMLastModifyDate": 0,
            "NMDashboardLink": "",
            "NMDashboardAPIToken": "",
            "NMDashboardSSLEnabled": true,
            "NMDashboardGRPCLink": "",
            "NMDashboardGRPCPort": "",
            "NMAgentSecret": "",
            "NMAgentSSLEnabled": false,
            "NMPushNotificationsToken": "",
            "NMPushToStartToken": "",
            "NMWatchPushNotificationsToken": "",
            "NMMacPushNotificationsToken": "",
            "NMLastViewedServerID": 0,
            "NMWatchLastViewedServerID": 0
        ]
        userDefaults.register(defaults: defaultValues)
    }
    
    static func saveNewDashboardConfigurations(dashboardLink: String, dashboardAPIToken: String, dashboardSSLEnabled: Bool) {
        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
        userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
        userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
        userDefaults.set(dashboardSSLEnabled, forKey: "NMDashboardSSLEnabled")
        
        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
        NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
        NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
        NSUbiquitousKeyValueStore().set(dashboardSSLEnabled, forKey: "NMDashboardSSLEnabled")
    }
    
    static func saveNewAgentConfigurations(dashboardGRPCLink: String, dashboardGRPCPort: String, agentSecret: String, agentSSLEnabled: Bool) {
        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
        userDefaults.set(dashboardGRPCLink, forKey: "NMDashboardGRPCLink")
        userDefaults.set(dashboardGRPCPort, forKey: "NMDashboardGRPCPort")
        userDefaults.set(agentSecret, forKey: "NMAgentSecret")
        userDefaults.set(agentSSLEnabled, forKey: "NMAgentSSLEnabled")
        
        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
        NSUbiquitousKeyValueStore().set(dashboardGRPCLink, forKey: "NMDashboardGRPCLink")
        NSUbiquitousKeyValueStore().set(dashboardGRPCPort, forKey: "NMDashboardGRPCPort")
        NSUbiquitousKeyValueStore().set(agentSecret, forKey: "NMAgentSecret")
        NSUbiquitousKeyValueStore().set(agentSSLEnabled, forKey: "NMAgentSSLEnabled")
    }
}
