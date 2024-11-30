//
//  GetAllServerResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/20/24.
//

import Foundation

struct GetAllServerResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [Server]?
    
    struct Server: Codable {
        let id: Int64
        let uuid: String
        let name: String
        let display_index: Int64
        @ISO8601Date var last_active: Date
        
        let host: Host
        let state: State
        let geoip: GeoIP?
    }
    
    struct Host: Codable {
        let platform: String?
        let platform_version: String?
        let cpu: [String]?
        let mem_total: Int64?
        let disk_total: Int64?
        let swap_total: Int64?
        let arch: String?
        let virtualization: String?
        let boot_time: Int64?
    }

    struct State: Codable {
        let cpu: Double?
        let mem_used: Int64?
        let disk_used: Int64?
        let swap_used: Int64?
        let net_in_transfer: Int64?
        let net_out_transfer: Int64?
        let net_in_speed: Int64?
        let net_out_speed: Int64?
        let uptime: Int64?
        let load_1: Double?
        let load_5: Double?
        let load_15: Double?
        let tcp_conn_count: Int64?
        let udp_conn_count: Int64?
        let process_count: Int64?
    }
    
    struct GeoIP: Codable {
        let ip: IP?
        let country_code: String?
    }
    
    struct IP: Codable {
        let ipv4_addr: String?
        let ipv6_addr: String?
    }
}
