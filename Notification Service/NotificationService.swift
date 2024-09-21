//
//  NotificationService.swift
//  Notification Service
//
//  Created by Junhui Lou on 9/20/24.
//

import UserNotifications
import SwiftData
import NezhaMobileData

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            Task {
                let createDataHandler = NezhaMobileData.shared.dataHandlerCreator()
                let dataHandler = await createDataHandler()
                _ = try? await dataHandler.newServerAlert(timestamp: Date(), title: bestAttemptContent.title, content: bestAttemptContent.body)
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
