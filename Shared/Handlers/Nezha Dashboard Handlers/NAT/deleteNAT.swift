//
//  deleteNAT.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

extension RequestHandler {
    static func deleteNAT(nats: [NATData]) async throws -> DeleteNATResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/batch-delete/nat") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [Int64] = nats.map({ $0.natID })
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
