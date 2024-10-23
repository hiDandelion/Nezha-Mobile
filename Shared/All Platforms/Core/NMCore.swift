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
}
