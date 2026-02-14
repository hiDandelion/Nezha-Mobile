//
//  GetCronResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct GetCronResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [Cron]?

    struct Cron: Codable {
        let id: Int64
        let name: String?
        let task_type: Int64?
        let scheduler: String?
        let command: String?
        let cover: Int64?
        let servers: [Int64]?
        let notification_group_id: Int64?
        let push_successful: Bool?
        let last_executed_at: String?
        let last_result: Bool?
        let cron_job_id: Int64?
        let created_at: String?
        let updated_at: String?
    }
}
