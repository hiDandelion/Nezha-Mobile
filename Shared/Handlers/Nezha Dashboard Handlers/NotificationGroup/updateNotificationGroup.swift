//
//  updateNotificationGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

extension RequestHandler {
    static func updateNotificationGroup(notificationGroup: NotificationGroup, name: String) async throws -> UpdateNotificationGroupResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/notification-group/\(notificationGroup.notificationGroupID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "name": name,
            "notifications": notificationGroup.notificationIDs
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }

    static func updateNotificationGroup(notificationGroup: NotificationGroup, notificationIDs: [Int64]) async throws -> UpdateNotificationGroupResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/notification-group/\(notificationGroup.notificationGroupID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "name": notificationGroup.name,
            "notifications": notificationIDs
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
