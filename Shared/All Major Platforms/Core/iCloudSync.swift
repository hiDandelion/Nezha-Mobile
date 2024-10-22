//
//  iCloudSync.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/17/24.
//

import Foundation
import CloudKit

extension NMCore {
    static func syncWithiCloud() {
        _ = NMCore.debugLog("Sync Info - Starting iCloud sync")
        
        let cloudStore = NSUbiquitousKeyValueStore.default
        
        _ = NMCore.debugLog("Sync Info - Starting sync")
        
        let keys = ["NMLastModifyDate", "NMDashboardLink", "NMDashboardAPIToken", "NMDashboardSSLEnabled", "NMDashboardGRPCLink", "NMDashboardGRPCPort", "NMAgentSecret", "NMAgentSSLEnabled"]
        
        let lastModifyDateLocal = NMCore.userDefaults.object(forKey: "NMLastModifyDate") as? Int
        let lastModifyDateRemote = cloudStore.object(forKey: "NMLastModifyDate") as? Int
        
        guard let lastModifyDateLocal, let lastModifyDateRemote else {
            _ = NMCore.debugLog("Sync Error - Unknown error")
            return
        }
        
        if lastModifyDateLocal > lastModifyDateRemote {
            _ = NMCore.debugLog("Sync Info - Local data is newer")
            
            // Sync from local to iCloud
            for key in keys {
                if let value = NMCore.userDefaults.object(forKey: key) {
                    _ = NMCore.debugLog("Sync Info - Syncing from local to iCloud: \(key) = \(value)")
                    cloudStore.set(value, forKey: key)
                } else {
                    _ = NMCore.debugLog("Sync Error - Key not found locally: \(key)")
                }
            }
            
            // Force sync
            let syncResult = cloudStore.synchronize()
            if syncResult {
                _ = NMCore.debugLog("Sync Info - iCloud sync successful")
            } else {
                _ = NMCore.debugLog("Sync Warning - iCloud sync may have failed")
            }
        }
        
        if lastModifyDateLocal < lastModifyDateRemote {
            _ = NMCore.debugLog("Sync Info - iCloud data is newer")
            
            // Sync from iCloud to local
            for key in keys {
                if let value = cloudStore.object(forKey: key) {
                    _ = NMCore.debugLog("Sync Info - Syncing from iCloud to local: \(key) = \(value)")
                    NMCore.userDefaults.set(value, forKey: key)
                } else {
                    _ = NMCore.debugLog("Sync Error - Key not found in iCloud: \(key)")
                }
            }
            
            // Force sync
            let syncResult = cloudStore.synchronize()
            if syncResult {
                _ = NMCore.debugLog("Sync Info - iCloud sync successful")
            } else {
                _ = NMCore.debugLog("Sync Warning - iCloud sync may have failed")
            }
        }
        
        if lastModifyDateLocal == lastModifyDateRemote {
            _ = NMCore.debugLog("Sync Info - Already up-to-date")
        }
        
        _ = NMCore.debugLog("Sync Info - iCloud sync process completed")
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
        
        syncWithiCloud()
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
        
        syncWithiCloud()
    }
}
