//
//  UpdateNotificationResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/4/24.
//

import Foundation

struct UpdateNotificationResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
