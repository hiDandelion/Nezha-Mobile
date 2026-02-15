//
//  getServiceHistory.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

extension RequestHandler {
    static func getServiceHistory(serviceID: Int64, period: String = "1d") async throws -> GetServiceHistoryResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/service/\(serviceID)/history?period=\(period)") else {
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
