//
//  AlertRuleData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct AlertRuleData: Codable, Identifiable, Hashable {
    let id: String
    let alertRuleID: Int64
    let notificationGroupID: Int64
    let name: String
    let isEnabled: Bool
    let triggerOption: Int64
    let triggerRule: String?
    let taskIDs: [Int64]
    let recoverTaskIDs: [Int64]
}
