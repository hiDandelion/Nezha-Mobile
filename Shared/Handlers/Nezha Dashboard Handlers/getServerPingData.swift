//
//  getServerPingData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import Foundation

extension RequestHandler {
    static func getServerPingData(serverID: String) async throws -> GetServerPingDataResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/monitor/\(serverID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "GET"
        request.setValue(configuration.dashboardAPIToken, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            return try decodeNezhaDashboardResponse(data: data)
        } catch {
            throw error
        }
    }
}
