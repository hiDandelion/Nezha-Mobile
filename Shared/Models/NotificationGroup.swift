//
//  NotificationGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

struct NotificationGroup: Codable, Identifiable, Hashable {
    var id: String {
        String(notificationGroupID)
    }
    let notificationGroupID: Int64
    let name: String
    let notificationIDs: [Int64]
}
