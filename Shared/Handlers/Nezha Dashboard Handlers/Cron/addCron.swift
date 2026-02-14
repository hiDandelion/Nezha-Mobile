//
//  addCron.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

extension RequestHandler {
    static func addCron(name: String, taskType: Int64, scheduler: String, command: String, cover: Int64, servers: [Int64], notificationGroupID: Int64, pushSuccessful: Bool) async throws -> AddCronResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/cron") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "name": name,
            "task_type": taskType,
            "scheduler": scheduler,
            "command": command,
            "cover": cover,
            "servers": servers,
            "notification_group_id": notificationGroupID,
            "push_successful": pushSuccessful
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
