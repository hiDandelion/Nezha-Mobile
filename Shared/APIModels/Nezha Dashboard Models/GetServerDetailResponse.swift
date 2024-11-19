//
//  GetServerDetailResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/20/24.
//

import Foundation

struct GetServerDetailResponse: Codable, NezhaDashboardBaseResponse {
    let code: Int
    let message: String
    let result: [Server]?
    
    struct Server: Codable, Identifiable, Hashable {
        let id: Int
        let name: String
        let tag: String
        let lastActive: Int64
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
        
        static func == (lhs: Server, rhs: Server) -> Bool {
            lhs.id == rhs.id && lhs.lastActive == rhs.lastActive
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(lastActive)
        }
    }
    
    struct ServerHost: Codable {
        let platform: String
        let platformVersion: String
        let cpu: [String]?
        let gpu: [String]?
        let memTotal: Int64
        let diskTotal: Int64
        let swapTotal: Int64
        let arch: String
        let virtualization: String
        let bootTime: Int64
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
        let memUsed: Int64
        let swapUsed: Int64
        let diskUsed: Int64
        let netInTransfer: Int64
        let netOutTransfer: Int64
        let netInSpeed: Int64
        let netOutSpeed: Int64
        let uptime: Int64
        let load1: Double
        let load5: Double
        let load15: Double
        let TCPConnectionCount: Int64
        let UDPConnectionCount: Int64
        let processCount: Int64
        
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
}
