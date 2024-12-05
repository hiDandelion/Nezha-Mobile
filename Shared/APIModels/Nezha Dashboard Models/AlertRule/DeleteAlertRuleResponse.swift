//
//  DeleteAlertRuleResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/5/24.
//

import Foundation

struct DeleteAlertRuleResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
