//
//  NotificationGroupData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct NotificationGroupData: Codable, Identifiable, Hashable {
    var id: String {
        String(notificationGroupID)
    }
    let notificationGroupID: Int64
    let name: String
    let notificationIDs: [Int64]
}
