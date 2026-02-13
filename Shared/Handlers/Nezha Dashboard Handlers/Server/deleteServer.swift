//
//  deleteServer.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/9/26.
//

import Foundation

extension RequestHandler {
    static func deleteServer(serverID: Int64) async throws -> DeleteServerResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/server") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [Int64] = [
            serverID
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
