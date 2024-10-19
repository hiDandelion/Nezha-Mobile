//
//  AppDelegate.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 9/12/24.
//

import WatchKit
import UserNotifications

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            _ = debugLog("Push Notification Info - Permission granted: \(granted)")
            if granted {
                self.registerForPushNotifications()
            }
        }
    }
    
    func registerForPushNotifications() {
        WKApplication.shared().registerForRemoteNotifications()
    }
    
    func applicationDidBecomeActive() {
        WKApplication.shared().registerForRemoteNotifications()
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let pushNotificationsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NMCore.userDefaults.set(pushNotificationsToken, forKey: "NMWatchPushNotificationsToken")
    }
}
