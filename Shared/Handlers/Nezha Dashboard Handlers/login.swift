//
//  login.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/29/24.
//

import Foundation

extension RequestHandler {
    static func login() async throws -> LoginResponse {
        guard let loginConfiguration = NMCore.getNezhaDashboardLoginConfiguration(endpoint: "/api/v1/login") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: loginConfiguration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": loginConfiguration.username,
            "password": loginConfiguration.password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
