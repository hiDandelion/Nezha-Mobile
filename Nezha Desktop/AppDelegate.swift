//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/18/24.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            _ = debugLog("Push Notification Info - Permission granted: \(granted)")
            if granted {
                self.registerForPushNotifications()
            }
        }
    }
    
    func applicationDidBecomeActive() {
        registerForPushNotifications()
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushNotificationsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        userDefaults.set(pushNotificationsToken, forKey: "NMMacPushNotificationsToken")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        if userDefaults.bool(forKey: "NMMenuBarEnabled") {
            NSApp.setActivationPolicy(.accessory)
            return false
        }
        return true
    }
    
    func registerForPushNotifications() {
        DispatchQueue.main.async {
            NSApp.registerForRemoteNotifications()
        }
    }
}
