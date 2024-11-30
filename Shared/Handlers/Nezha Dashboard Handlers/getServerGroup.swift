//
//  getServerGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

extension RequestHandler {
    static func getServerGroup() async throws -> GetServerGroupResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/server-group") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
