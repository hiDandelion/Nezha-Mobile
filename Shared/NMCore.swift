//
//  NMCore.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import Foundation

class NMCore {
    static let userGuideURL: URL = URL(string: "https://support.argsment.com/nezha-mobile/user-guide")!
    static let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    
    static func debugLog(_ message: Any) -> Any? {
        #if DEBUG
        print("Debug - \(message)")
        #endif
        return nil
    }
    
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
    
    struct NezhaDashboardConfiguration {
        let dashboardLink: String
        let dashboardAPIToken: String
        let url: URL
    }
    
    static func getNezhaDashboardConfiguration(endpoint: String) -> NezhaDashboardConfiguration? {
        guard let dashboardLink = NMCore.userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = NMCore.userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "\(NMCore.userDefaults.bool(forKey: "NMDashboardSSLEnabled") ? "https" : "http")://\(dashboardLink)\(endpoint)") else {
            return nil
        }
        return NezhaDashboardConfiguration(
            dashboardLink: dashboardLink,
            dashboardAPIToken: dashboardAPIToken,
            url: url
        )
    }
}
