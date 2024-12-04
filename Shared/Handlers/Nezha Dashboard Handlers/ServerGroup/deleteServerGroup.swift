//
//  deleteServerGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

extension RequestHandler {
    static func deleteServerGroup(serverGroups: [ServerGroup]) async throws -> DeleteServerGroupResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/server-group") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let loginResponse = try await login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("nz-jwt=\(token)", forHTTPHeaderField: "Cookie")
        
        let body: [Int64] = serverGroups.map({ $0.serverGroupID })
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
