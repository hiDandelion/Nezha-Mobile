//
//  GetServiceHistoryResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

struct GetServiceHistoryResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: ServiceHistoryData?

    struct ServiceHistoryData: Codable {
        let service_id: Int64
        let service_name: String?
        let servers: [ServerServiceStats]
    }

    struct ServerServiceStats: Codable {
        let server_id: Int64
        let server_name: String?
        let stats: ServiceHistorySummary
    }

    struct ServiceHistorySummary: Codable {
        let avg_delay: Double
        let up_percent: Float
        let total_up: Int64
        let total_down: Int64
        let data_points: [DataPoint]?
    }

    struct DataPoint: Codable {
        let ts: Int64
        let delay: Double
        let status: UInt8
    }
}
