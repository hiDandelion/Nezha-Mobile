//
//  getAlertRule.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

extension RequestHandler {
    static func getAlertRule() async throws -> GetAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let loginResponse = try await login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "GET"
        request.setValue("nz-jwt=\(token)", forHTTPHeaderField: "Cookie")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
