//
//  GetAlertRuleResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation
import SwiftyJSON

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
        var rules: String?
        let fail_trigger_tasks: [Int64]
        let recover_trigger_tasks: [Int64]
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case enable
            case trigger_mode
            case notification_group_id
            case rules
            case fail_trigger_tasks
            case recover_trigger_tasks
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(Int64.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            enable = try container.decode(Bool.self, forKey: .enable)
            trigger_mode = try container.decode(Int64.self, forKey: .trigger_mode)
            notification_group_id = try container.decode(Int64.self, forKey: .notification_group_id)
            fail_trigger_tasks = try container.decode([Int64].self, forKey: .fail_trigger_tasks)
            recover_trigger_tasks = try container.decode([Int64].self, forKey: .recover_trigger_tasks)
            
            // Handle decoding rules
            let rulesValue = try container.decode(JSON.self, forKey: .rules)
            rules = rulesValue.rawString()?.components(separatedBy: .whitespacesAndNewlines).joined()
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(enable, forKey: .enable)
            try container.encode(trigger_mode, forKey: .trigger_mode)
            try container.encode(notification_group_id, forKey: .notification_group_id)
            try container.encode(fail_trigger_tasks, forKey: .fail_trigger_tasks)
            try container.encode(recover_trigger_tasks, forKey: .recover_trigger_tasks)
            try container.encode(rules, forKey: .rules)
        }
    }
}
