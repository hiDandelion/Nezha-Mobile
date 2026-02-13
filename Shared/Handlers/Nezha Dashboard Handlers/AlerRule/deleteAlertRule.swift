//
//  deleteAlertRule.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/5/24.
//

import Foundation

extension RequestHandler {
    static func deleteAlertRule(alertRules: [AlertRuleData]) async throws -> DeleteAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/alert-rule") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [Int64] = alertRules.map({ $0.alertRuleID })
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
