//
//  updateNotification.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/4/24.
//

import Foundation

extension RequestHandler {
    static func updateNotification(notification: NotificationData, name: String) async throws -> UpdateNotificationResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/notification/\(notification.notificationID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "url": notification.url,
            "request_method": notification.requestMethod,
            "request_type": notification.requestType,
            "request_header": notification.requestHeader,
            "request_body": notification.requestBody,
            "verify_tls": notification.isVerifyTLS,
            "skip_check": true
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
