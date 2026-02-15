//
//  getServerMetrics.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

extension RequestHandler {
    static func getServerMetrics(serverID: Int64, metric: String, period: String = "1d") async throws -> GetServerMetricsResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/server/\(serverID)/metrics?metric=\(metric)&period=\(period)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "GET"

        if let token = try? await getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
