//
//  APIResponseModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/5/24.
//

import Foundation

struct GetServerDetailResponse: Codable {
    let code: Int
    let message: String
    let result: [Server]?
}

struct Server: Codable {
    let id: Int
    let name: String
    let tag: String
    let lastActive: Int
    let IPv4: String
    let IPv6: String
    let validIP: String
    let displayIndex: Int?
    let host: ServerHost
    let status: ServerStatus
    
    enum CodingKeys: String, CodingKey {
        case id, name, tag
        case lastActive = "last_active"
        case IPv4 = "ipv4"
        case IPv6 = "ipv6"
        case validIP = "valid_ip"
        case displayIndex = "display_index"
        case host, status
    }
}

struct ServerHost: Codable {
    let platform: String
    let platformVersion: String
    let cpu: [String]?
    let gpu: [String]?
    let memTotal: Int
    let diskTotal: Int
    let swapTotal: Int
    let arch: String
    let virtualization: String
    let bootTime: Int
    let countryCode: String
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case platform = "Platform"
        case platformVersion = "PlatformVersion"
        case cpu = "CPU"
        case gpu = "GPU"
        case memTotal = "MemTotal"
        case diskTotal = "DiskTotal"
        case swapTotal = "SwapTotal"
        case arch = "Arch"
        case virtualization = "Virtualization"
        case bootTime = "BootTime"
        case countryCode = "CountryCode"
        case version = "Version"
    }
}

struct ServerStatus: Codable {
    let cpu: Double
    let memUsed: Int
    let swapUsed: Int
    let diskUsed: Int
    let netInTransfer: Int
    let netOutTransfer: Int
    let netInSpeed: Int
    let netOutSpeed: Int
    let uptime: Int
    let load1: Double
    let load5: Double
    let load15: Double
    let TCPConnectionCount: Int
    let UDPConnectionCount: Int
    let processCount: Int
    
    enum CodingKeys: String, CodingKey {
        case cpu = "CPU"
        case memUsed = "MemUsed"
        case swapUsed = "SwapUsed"
        case diskUsed = "DiskUsed"
        case netInTransfer = "NetInTransfer"
        case netOutTransfer = "NetOutTransfer"
        case netInSpeed = "NetInSpeed"
        case netOutSpeed = "NetOutSpeed"
        case uptime = "Uptime"
        case load1 = "Load1"
        case load5 = "Load5"
        case load15 = "Load15"
        case TCPConnectionCount = "TcpConnCount"
        case UDPConnectionCount = "UdpConnCount"
        case processCount = "ProcessCount"
    }
}

struct GetServerPingDataResponse: Codable {
    let code: Int
    let message: String
    let result: [PingData]?
}

struct PingData: Codable, Identifiable {
    let monitorId: Int
    let serverId: Int
    let monitorName: String
    let serverName: String
    let createdAt: [Date]
    let avgDelay: [Double]
    
    var id: Int { monitorId }
    
    enum CodingKeys: String, CodingKey {
        case monitorId = "monitor_id"
        case serverId = "server_id"
        case monitorName = "monitor_name"
        case serverName = "server_name"
        case createdAt = "created_at"
        case avgDelay = "avg_delay"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        monitorId = try container.decode(Int.self, forKey: .monitorId)
        serverId = try container.decode(Int.self, forKey: .serverId)
        monitorName = try container.decode(String.self, forKey: .monitorName)
        serverName = try container.decode(String.self, forKey: .serverName)
        
        let createdAtTimestamps = try container.decode([Double].self, forKey: .createdAt)
        createdAt = createdAtTimestamps.map { Date(timeIntervalSince1970: $0 / 1000) }
        
        avgDelay = try container.decode([Double].self, forKey: .avgDelay)
    }
}
