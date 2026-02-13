//
//  getTerminalSession.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/4/24.
//

import Foundation

extension RequestHandler {
    static func getTerminalSession(serverID: Int64) async throws -> (GetTerminalSessionResponse, String) {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/terminal") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "server_id": serverID
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let getTerminalSessionResponse: GetTerminalSessionResponse = try decodeNezhaDashboardResponse(data: data)
        return (getTerminalSessionResponse, token)
    }
}
