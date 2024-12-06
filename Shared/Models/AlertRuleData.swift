//
//  AlertRuleData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation
import SwiftyJSON

struct AlertRuleData: Codable, Identifiable, Hashable {
    var id: String {
        String(alertRuleID)
    }
    let alertRuleID: Int64
    let notificationGroupID: Int64
    let name: String
    let isEnabled: Bool
    let triggerOption: Int64
    let triggerRule: JSON
    let taskIDs: [Int64]
    let recoverTaskIDs: [Int64]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(alertRuleID)
        hasher.combine(notificationGroupID)
        hasher.combine(name)
        hasher.combine(isEnabled)
        hasher.combine(triggerOption)
        hasher.combine(triggerRule.rawString())
        hasher.combine(taskIDs)
        hasher.combine(recoverTaskIDs)
    }
}
