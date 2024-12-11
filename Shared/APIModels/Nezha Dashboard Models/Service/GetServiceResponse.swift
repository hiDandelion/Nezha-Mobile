//
//  GetServiceResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation
import SwiftyJSON

struct GetServiceResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [Service]?
    
    struct Service: Codable {
        let id: Int64
        let name: String?
        let type: Int64?
        let target: String?
        let duration: Int64?
        let notification_group_id: Int64?
        let cover: Int64?
        let fail_trigger_tasks: [Int64]?
        let recover_trigger_tasks: [Int64]?
        let min_latency: Int64?
        let max_latency: Int64?
        let skip_servers: JSON
    }
}
