//
//  GetServiceResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/20/24.
//

import Foundation

struct GetServiceResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [Service]?
    
    struct Service: Codable {
        let monitor_id: Int64
        let server_id: Int64
        let monitor_name: String
        let server_name: String
        @MillisecondTimestamps var created_at: [Date]
        let avg_delay: [Double]
    }
}
