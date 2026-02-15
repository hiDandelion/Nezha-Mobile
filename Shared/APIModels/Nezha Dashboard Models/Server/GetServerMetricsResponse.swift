//
//  GetServerMetricsResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

struct GetServerMetricsResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: ServerMetricsData?

    struct ServerMetricsData: Codable {
        let server_id: Int64
        let server_name: String?
        let metric: String
        let data_points: [MetricsDataPoint]
    }

    struct MetricsDataPoint: Codable {
        let ts: Int64
        let value: Double
    }
}
