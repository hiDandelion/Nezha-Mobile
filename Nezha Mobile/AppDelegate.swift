//
//  AppDelegate.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI
import UserNotifications
import ActivityKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var app: NezhaMobileApp?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
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
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            print("Got notification title: ", response.notification.request.content.title)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
}
