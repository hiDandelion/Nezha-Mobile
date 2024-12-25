//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/18/24.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let state: NMState = .init()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                _ = NMCore.debugLog("Push Notification Info - Permission granted: \(granted)")
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
        NMCore.userDefaults.set(pushNotificationsToken, forKey: "NMMacPushNotificationsToken")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let title = response.notification.request.content.title
        let body = response.notification.request.content.body
        
        _ = NMCore.debugLog("Notification Info - Title: \(title), Body: \(body)")
        
        DispatchQueue.main.async { [self] in
            state.incomingAlert = (title: title, body: body)
            NSWorkspace.shared.open(URL(string: "nezha://alert-details")!)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if NMCore.userDefaults.bool(forKey: "NMMenuBarEnabled") {
            NSApp.setActivationPolicy(.accessory)
            return false
        }
        return true
    }
}

class NotificationState: ObservableObject {
    @Published var notificationData: (title: String, body: String)?
}
