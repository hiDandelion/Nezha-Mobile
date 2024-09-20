//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/18/24.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let notificationState: NotificationState = NotificationState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                _ = debugLog("Push Notification Info - Permission granted: \(granted)")
                if granted {
                    self.registerForPushNotifications()
                }
            }
    }
    
    func applicationDidBecomeActive() {
        registerForPushNotifications()
    }
    
    func registerForPushNotifications() {
        DispatchQueue.main.async {
            NSApp.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushNotificationsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        userDefaults.set(pushNotificationsToken, forKey: "NMMacPushNotificationsToken")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let title = response.notification.request.content.title
        let body = response.notification.request.content.body
        
        _ = debugLog("Notification Info - Title: \(title), Body: \(body)")
        
        DispatchQueue.main.async {
            self.notificationState.notificationData = (title: title, body: body)
            NSWorkspace.shared.open(URL(string: "nezha://alert-details")!)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        if userDefaults.bool(forKey: "NMMenuBarEnabled") {
            NSApp.setActivationPolicy(.accessory)
            return false
        }
        return true
    }
}

class NotificationState: ObservableObject {
    @Published var notificationData: (title: String, body: String)?
}
