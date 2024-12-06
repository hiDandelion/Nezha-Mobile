//
//  NotificationData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct NotificationData: Codable, Identifiable, Hashable {
    var id: String {
        String(notificationID)
    }
    let notificationID: Int64
    let name: String
    let url: String
    let requestMethod: Int64
    let requestType: Int64
    let requestHeader: String
    let requestBody: String
    let isVerifyTLS: Bool
}
