//
//  addNotification.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/2/24.
//

import Foundation

extension RequestHandler {
    static func addNotification(name: String, pushNotificationsToken: String) async throws -> AddNotificationResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/notification") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let loginResponse = try await login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "url": NMCore.NMAPNServiceURLString,
            "request_method": 2,
            "request_type": 1,
            "request_header": "",
            "request_body":
"""
{
"iOSDeviceToken": "\(pushNotificationsToken)",
"title": "\(String(localized: "Alert"))",
"body": "#NEZHA#"
}
""",
            "skip_check": true
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
