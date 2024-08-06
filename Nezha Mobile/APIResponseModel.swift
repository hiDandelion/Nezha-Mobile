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
    let iPv4: String
    let iPv6: String
    let validIP: String
    let displayIndex: Int
    let host: ServerHost
    let status: ServerStatus
    
    enum CodingKeys: String, CodingKey {
        case id, name, tag
        case lastActive = "last_active"
        case iPv4 = "ipv4"
        case iPv6 = "ipv6"
        case validIP = "valid_ip"
        case displayIndex = "display_index"
        case host, status
    }
}

struct ServerHost: Codable {
    let platform: String
    let platformVersion: String
    let cpu: [String]?
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
