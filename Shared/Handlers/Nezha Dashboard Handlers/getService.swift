//
//  getService.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import Foundation

extension RequestHandler {
    static func getService(serverID: String) async throws -> GetServiceResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/service/\(serverID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
