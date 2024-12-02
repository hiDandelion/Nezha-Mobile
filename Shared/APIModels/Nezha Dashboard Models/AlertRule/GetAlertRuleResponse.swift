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
        let trigger_mode: Int64
        let notification_group_id: Int64
        var rules: [Rule]
        let fail_trigger_tasks: [Int64]
        let recover_trigger_tasks: [Int64]
    }
    
    struct Rule: Codable {
        let type: String?
        let duration: Int64?
        let min: Int64?
        let max: Int64?
        let cover: Int64?
    }
}
