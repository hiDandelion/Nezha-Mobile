//
//  NotificationData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct NotificationData: Codable, Identifiable, Hashable {
    let id: String
    let notificationID: Int64
    let name: String
    let url: String
    let requestBody: String
}
