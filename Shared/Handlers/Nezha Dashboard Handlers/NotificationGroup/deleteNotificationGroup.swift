//
//  deleteNotificationGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

extension RequestHandler {
    static func deleteNotificationGroup(notificationGroups: [NotificationGroup]) async throws -> DeleteNotificationGroupResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/notification-group") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [Int64] = notificationGroups.map({ $0.notificationGroupID })
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
