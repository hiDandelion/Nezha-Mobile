//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI
import UserNotifications
import ActivityKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let notificationState: NotificationState
    
    override init() {
        self.notificationState = NotificationState()
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                _ = debugLog("Push Notification Info - Permission granted: \(granted)")
            }
        
        if #available(iOS 17.2, *) {
            Task {
                for await data in Activity<LiveActivityAttributes>.pushToStartTokenUpdates {
                    let pushToStartToken = data.map {String(format: "%02.2hhx", $0)}.joined()
                    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
                    userDefaults.set(pushToStartToken, forKey: "NMPushToStartToken")
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushNotificationsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        userDefaults.set(pushNotificationsToken, forKey: "NMPushNotificationsToken")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let title = response.notification.request.content.title
        let body = response.notification.request.content.body
        
        _ = debugLog("Notification Info - Title: \(title), Body: \(body)")
        
        DispatchQueue.main.async { [self] in
            notificationState.notificationData = (title: title, body: body)
            notificationState.shouldNavigateToNotificationView = true
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
}

class NotificationState: ObservableObject {
    @Published var shouldNavigateToNotificationView = false
    @Published var notificationData: (title: String, body: String)?
}
