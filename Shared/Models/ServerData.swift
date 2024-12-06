//
//  ServerData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/26/24.
//

import Foundation

struct ServerData: Codable, Identifiable, Hashable {
    var id: String {
        String(serverID)
    }
    let serverID: Int64
    let name: String
    let displayIndex: Int64
    let lastActive: Date
    
    let ipv4: String
    let ipv6: String
    let countryCode: String
    
    let host: Host
    let status: Status
    
    struct Host: Codable, Hashable {
        let platform: String
        let platformVersion: String
        let cpu: [String]
        let memoryTotal: Int64
        let swapTotal: Int64
        let diskTotal: Int64
        let architecture: String
        let virtualization: String
        let bootTime: Int64
    }
    
    struct Status: Codable, Hashable {
        let cpuUsed: Double
        let memoryUsed: Int64
        let swapUsed: Int64
        let diskUsed: Int64
        let networkIn: Int64
        let networkOut: Int64
        let networkInSpeed: Int64
        let networkOutSpeed: Int64
        let uptime: Int64
        let load1: Double
        let load5: Double
        let load15: Double
        let tcpConnectionCount: Int64
        let udpConnectionCount: Int64
        let processCount: Int64
    }
}
