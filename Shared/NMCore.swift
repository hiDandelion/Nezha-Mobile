//
//  NMCore.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import Foundation

class NMCore {
    static let NMLastModifyDate = "NMLastModifyDate"
    static let NMDashboardLink = "NMDashboardLink"
    static let NMDashboardUsername = "NMDashboardUsername"
    static let NMDashboardPassword = "NMDashboardPassword"
    static let NMDashboardSSLEnabled = "NMDashboardSSLEnabled"
    static let NMDashboardGRPCLink = "NMDashboardGRPCLink"
    static let NMDashboardGRPCPort = "NMDashboardGRPCPort"
    static let NMAgentSecret = "NMAgentSecret"
    static let NMAgentSSLEnabled = "NMAgentSSLEnabled"
    static let NMPushNotificationsToken = "NMPushNotificationsToken"
    static let NMWatchPushNotificationsToken = "NMWatchPushNotificationsToken"
    static let NMMacPushNotificationsToken = "NMMacPushNotificationsToken"
    
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
            NMLastModifyDate: 0,
            NMDashboardLink: "",
            NMDashboardUsername: "",
            NMDashboardPassword: "",
            NMDashboardSSLEnabled: "",
            NMDashboardGRPCPort: "",
            NMAgentSecret: "",
            NMAgentSSLEnabled: false,
            NMPushNotificationsToken: "",
            NMWatchPushNotificationsToken: "",
            NMMacPushNotificationsToken: ""
        ]
        userDefaults.register(defaults: defaultValues)
    }
    
    // Save dashboard configuration
    static func saveNewDashboardConfigurations(dashboardLink: String, dashboardUsername: String, dashboardPassword: String, dashboardSSLEnabled: Bool) {
        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        userDefaults.set(dashboardLink, forKey: NMDashboardLink)
        userDefaults.set(dashboardUsername, forKey: NMDashboardUsername)
        userDefaults.set(dashboardPassword, forKey: NMDashboardPassword)
        userDefaults.set(dashboardSSLEnabled, forKey: NMDashboardSSLEnabled)
        
        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        NSUbiquitousKeyValueStore().set(dashboardLink, forKey: NMDashboardLink)
        NSUbiquitousKeyValueStore().set(dashboardUsername, forKey: NMDashboardUsername)
        NSUbiquitousKeyValueStore().set(dashboardPassword, forKey: NMDashboardPassword)
        NSUbiquitousKeyValueStore().set(dashboardSSLEnabled, forKey: NMDashboardSSLEnabled)
        
        syncWithiCloud()
    }
    
    // Save agent configuration
    static func saveNewAgentConfigurations(dashboardGRPCLink: String, dashboardGRPCPort: String, agentSecret: String, agentSSLEnabled: Bool) {
        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        userDefaults.set(dashboardGRPCLink, forKey: NMDashboardGRPCLink)
        userDefaults.set(dashboardGRPCPort, forKey: NMDashboardGRPCPort)
        userDefaults.set(agentSecret, forKey: NMAgentSecret)
        userDefaults.set(agentSSLEnabled, forKey: NMAgentSSLEnabled)
        
        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        NSUbiquitousKeyValueStore().set(dashboardGRPCLink, forKey: NMDashboardGRPCLink)
        NSUbiquitousKeyValueStore().set(dashboardGRPCPort, forKey: NMDashboardGRPCPort)
        NSUbiquitousKeyValueStore().set(agentSecret, forKey: NMAgentSecret)
        NSUbiquitousKeyValueStore().set(agentSSLEnabled, forKey: NMAgentSSLEnabled)
        
        syncWithiCloud()
    }
    
    // Get configuration
    struct NezhaDashboardConfiguration {
        let url: URL
    }
    
    static func getNezhaDashboardConfiguration(endpoint: String) -> NezhaDashboardConfiguration? {
        let dashboardLink = NMCore.userDefaults.string(forKey: NMDashboardLink)!
        guard let url = URL(string: "\(NMCore.userDefaults.bool(forKey: NMDashboardSSLEnabled) ? "https" : "http")://\(dashboardLink)\(endpoint)") else {
            _ = debugLog("Core Error - Cannot construct dashboard URL.")
            return nil
        }
        
        return NezhaDashboardConfiguration(
            url: url
        )
    }
    
    // Get login configuration
    struct NezhaDashboardLoginConfiguration {
        let url: URL
        let username: String
        let password: String
    }
    
    static func getNezhaDashboardLoginConfiguration(endpoint: String) -> NezhaDashboardLoginConfiguration? {
        let dashboardLink = NMCore.userDefaults.string(forKey: NMDashboardLink)!
        guard let url = URL(string: "\(NMCore.userDefaults.bool(forKey: NMDashboardSSLEnabled) ? "https" : "http")://\(dashboardLink)\(endpoint)") else {
            _ = debugLog("Core Error - Cannot construct dashboard URL.")
            return nil
        }
        
        let dashboardUsername = getNezhaDashboardUsername()
        let dashboardPassword = getNezhaDashboardPassword()
        
        return NezhaDashboardLoginConfiguration(
            url: url,
            username: dashboardUsername,
            password: dashboardPassword
        )
    }
    
    // Helper functions
    static func getNezhaDashboardLink() -> String {
        return NMCore.userDefaults.string(forKey: NMDashboardLink)!
    }
    
    static func getNezhaDashboardUsername() -> String {
        return NMCore.userDefaults.string(forKey: NMDashboardUsername)!
    }
    
    static func getNezhaDashboardPassword() -> String {
        return NMCore.userDefaults.string(forKey: NMDashboardPassword)!
    }
    
    static func getIsNezhaDashboardSSLEnabled() -> Bool {
        return NMCore.userDefaults.bool(forKey: NMDashboardSSLEnabled)
    }
}
