//
//  AddNotificationResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/2/24.
//

import Foundation

struct AddNotificationResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
