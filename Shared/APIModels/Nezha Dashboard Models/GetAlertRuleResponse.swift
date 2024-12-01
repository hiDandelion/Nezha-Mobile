//
//  GetAlertRuleResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct GetAlertRuleResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [AlertRule]?
    
    struct AlertRule: Codable {
        let id: Int64
        let name: String
        let enable: Bool
        let notification_group_id: Int64
    }
}
