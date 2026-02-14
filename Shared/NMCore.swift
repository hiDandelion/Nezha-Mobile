//
//  NMCore.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import Foundation
import KeychainSwift

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
    
    static let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    static let keychain = KeychainSwift()
    static var cachedPassword: String?
    
    static let apnsSendAlertURLString: String = "https://nezha-mobile-apns.argsment.com/api/send-alert"
    
    static let userGuideURL: URL = URL(string: "https://support.argsment.com/nezha-mobile/user-guide")!
    
    static func debugLog(_ message: Any) -> Any? {
        #if DEBUG
        print("Debug - \(message)")
        #endif
        return nil
    }
    
    static var isNezhaDashboardConfigured: Bool {
        if getNezhaDashboardLink() == "" { return false }
        if getNezhaDashboardUsername() == "" { return false }
        if getNezhaDashboardPassword() == "" { return false }
        return true
    }
    
    // MARK: - App Initialization
    static func registerUserDefaults() {
        let defaultValues: [String: Any] = [
            NMLastModifyDate: 0,
            NMDashboardLink: "",
            NMDashboardUsername: "",
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
    
    static func registerKeychain() {
        keychain.accessGroup = "C7AS5D38Q8.com.argsment.Nezha-Mobile"
        keychain.synchronizable = true
    }
    
    // Save dashboard configuration
    static func saveNewDashboardConfigurations(dashboardLink: String, dashboardUsername: String, dashboardPassword: String, dashboardSSLEnabled: Bool) {
        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        userDefaults.set(dashboardLink, forKey: NMDashboardLink)
        userDefaults.set(dashboardUsername, forKey: NMDashboardUsername)
        userDefaults.set(dashboardSSLEnabled, forKey: NMDashboardSSLEnabled)
        
        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: NMLastModifyDate)
        NSUbiquitousKeyValueStore().set(dashboardLink, forKey: NMDashboardLink)
        NSUbiquitousKeyValueStore().set(dashboardUsername, forKey: NMDashboardUsername)
        NSUbiquitousKeyValueStore().set(dashboardSSLEnabled, forKey: NMDashboardSSLEnabled)
        
        syncWithiCloud()
        
        keychain.set(dashboardPassword, forKey: NMDashboardPassword)

        Task { await TokenManager.shared.invalidateToken() }
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
        return userDefaults.string(forKey: NMDashboardLink)!
    }
    
    static func getNezhaDashboardUsername() -> String {
        return userDefaults.string(forKey: NMDashboardUsername)!
    }
    
    static func getNezhaDashboardPassword() -> String {
        if let cachedPassword {
            return cachedPassword
        }
        else {
            cachedPassword = keychain.get(NMDashboardPassword)
            return cachedPassword ?? ""
        }
    }
    
    static func getIsNezhaDashboardSSLEnabled() -> Bool {
        return userDefaults.bool(forKey: NMDashboardSSLEnabled)
    }
}
