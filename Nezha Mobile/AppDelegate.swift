//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData
import UserNotifications
import ActivityKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let state: NMState = .init()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                _ = NMCore.debugLog("Push Notification Info - Permission granted: \(granted)")
            }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushNotificationsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NMCore.userDefaults.set(pushNotificationsToken, forKey: NMCore.NMPushNotificationsToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let title = response.notification.request.content.title
        let body = response.notification.request.content.body
        
        _ = NMCore.debugLog("Notification Info - Title: \(title), Body: \(body)")
        
        DispatchQueue.main.async { [self] in
            state.tab = .alerts
            state.path.append(ServerAlert(timestamp: Date(), title: title, content: body))
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
}
