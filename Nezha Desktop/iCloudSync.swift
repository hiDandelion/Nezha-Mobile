//
//  iCloudSync.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/17/24.
//

import Foundation
import CloudKit

func syncWithiCloud() {
    _ = debugLog("Sync Info - Starting iCloud sync")
    
    guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") else {
        _ = debugLog("Sync Error - Unable to access UserDefaults")
        return
    }
    
    let cloudStore = NSUbiquitousKeyValueStore.default
    
    _ = debugLog("Sync Info - Starting sync")
    
    let keys = ["NMLastModifyDate", "NMDashboardLink", "NMDashboardAPIToken"]
    
    let lastModifyDateLocal = userDefaults.object(forKey: "NMLastModifyDate") as? Int
    let lastModifyDateRemote = cloudStore.object(forKey: "NMLastModifyDate") as? Int
    
    guard let lastModifyDateLocal, let lastModifyDateRemote else {
        _ = debugLog("Sync Error - Unknown error")
        return
    }
    
    if lastModifyDateLocal > lastModifyDateRemote {
        _ = debugLog("Sync Info - Local data is newer")
        
        // Sync from local to iCloud
        for key in keys {
            if let value = userDefaults.object(forKey: key) {
                _ = debugLog("Sync Info - Syncing from local to iCloud: \(key) = \(value)")
                cloudStore.set(value, forKey: key)
            } else {
                _ = debugLog("Sync Error - Key not found locally: \(key)")
            }
        }
        
        // Force sync
        let syncResult = cloudStore.synchronize()
        if syncResult {
            _ = debugLog("Sync Info - iCloud sync successful")
        } else {
            _ = debugLog("Sync Warning - iCloud sync may have failed")
        }
    }
    
    if lastModifyDateLocal < lastModifyDateRemote {
        _ = debugLog("Sync Info - iCloud data is newer")
        
        // Sync from iCloud to local
        for key in keys {
            if let value = cloudStore.object(forKey: key) {
                _ = debugLog("Sync Info - Syncing from iCloud to local: \(key) = \(value)")
                userDefaults.set(value, forKey: key)
            } else {
                _ = debugLog("Sync Error - Key not found in iCloud: \(key)")
            }
        }
        
        // Force sync
        let syncResult = cloudStore.synchronize()
        if syncResult {
            _ = debugLog("Sync Info - iCloud sync successful")
        } else {
            _ = debugLog("Sync Warning - iCloud sync may have failed")
        }
    }
    
    if lastModifyDateLocal == lastModifyDateRemote {
        _ = debugLog("Sync Info - Already up-to-date")
    }
    
    _ = debugLog("Sync Info - iCloud sync process completed")
}
