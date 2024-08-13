//
//  iCloudSync.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import Foundation

func syncWithiCloud() {
    debugLog("Sync Info - Starting iCloud sync")
    
    guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") else {
        debugLog("Sync Error - Unable to access UserDefaults")
        return
    }
    
    let cloudStore = NSUbiquitousKeyValueStore.default
    
    if FileManager.default.ubiquityIdentityToken != nil {
        debugLog("Sync Info - iCloud is available, starting sync")
        
        let keys = ["NMDashboardLink", "NMDashboardAPIToken", "NMLastModifyDate"]
        
        let lastModifyDateLocal = userDefaults.object(forKey: "NMLastModifyDate") as? Int
        let lastModifyDateRemote = cloudStore.object(forKey: "NMLastModifyDate") as? Int
        
        if let lastModifyDateLocal, let lastModifyDateRemote {
            if lastModifyDateLocal > lastModifyDateRemote {
                debugLog("Sync Info - Local data is newer")
                
                // Sync from local to iCloud
                for key in keys {
                    if let value = userDefaults.object(forKey: key) {
                        debugLog("Sync Info - Syncing from local to iCloud: \(key) = \(value)")
                        cloudStore.set(value, forKey: key)
                    } else {
                        debugLog("Sync Error - Key not found locally: \(key)")
                    }
                }
                
                // Force sync
                let syncResult = cloudStore.synchronize()
                if syncResult {
                    debugLog("Sync Info - iCloud sync successful")
                } else {
                    debugLog("Sync Warning - iCloud sync may have failed")
                }
            }
            
            if lastModifyDateLocal < lastModifyDateRemote {
                debugLog("Sync Info - iCloud data is newer")
                
                // Sync from iCloud to local
                for key in keys {
                    if let value = cloudStore.object(forKey: key) {
                        debugLog("Sync Info - Syncing from iCloud to local: \(key) = \(value)")
                        userDefaults.set(value, forKey: key)
                    } else {
                        debugLog("Sync Error - Key not found in iCloud: \(key)")
                    }
                }
                
                // Force sync
                let syncResult = cloudStore.synchronize()
                if syncResult {
                    debugLog("Sync Info - iCloud sync successful")
                } else {
                    debugLog("Sync Warning - iCloud sync may have failed")
                }
            }
            
            if lastModifyDateLocal == lastModifyDateRemote {
                debugLog("Sync Info - Already up-to-date")
            }
        }
        else {
            debugLog("Sync Warning - Data not exist or corrupted, abandon this sync")
        }
    } else {
        debugLog("Sync Error - iCloud is not available")
    }
    
    debugLog("Sync Info - iCloud sync process completed")
}
