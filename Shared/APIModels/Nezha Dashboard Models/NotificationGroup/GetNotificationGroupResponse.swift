//
//  GetNotificationGroupResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct GetNotificationGroupResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [NotificationGroupItem]?

    struct NotificationGroupItem: Codable {
        let group: Group
        let notifications: [Int64]?

        struct Group: Codable {
            let id: Int64
            let name: String
        }
    }
}
