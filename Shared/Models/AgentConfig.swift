//
//  AgentConfig.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct AgentConfig: Codable {
    var debug: Bool?
    var disable_auto_update: Bool?
    var disable_command_execute: Bool?
    var disable_force_update: Bool?
    var disable_nat: Bool?
    var disable_send_query: Bool?
    var gpu: Bool?
    var temperature: Bool?
    var skip_connection_count: Bool?
    var skip_procs_count: Bool?
    var hard_drive_partition_allowlist: [String]?
    var nic_allowlist: [String]?
    var ip_report_period: Int64?
    var report_delay: Int64?
}
