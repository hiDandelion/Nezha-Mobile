//
//  deleteCron.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

extension RequestHandler {
    static func deleteCron(crons: [CronData]) async throws -> DeleteCronResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/cron") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [Int64] = crons.map({ $0.cronID })
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
