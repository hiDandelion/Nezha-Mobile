//
//  GetNotificationResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct GetNotificationResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [Notification]?
    
    struct Notification: Codable {
        let id: Int64
        let name: String
        let url: String
        let request_method: Int64
        let request_type: Int64
        let request_header: String
        let request_body: String
        let verify_tls: Bool
    }
}
