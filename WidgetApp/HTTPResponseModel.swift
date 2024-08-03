//
//  HTTPResponseModel.swift
//  WidgetAppExtension
//
//  Created by Junhui Lou on 8/2/24.
//

struct HTTPResponse: Codable {
    let code: Int
    let message: String
    let result: [Server]?
}

struct Server: Codable, Identifiable {
    let id: Int
    let name: String
    let ipv4: String
    let ipv6: String
    let host: ServerHost
    let status: ServerStatus
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case ipv4, ipv6
        case host, status
    }
}

struct ServerHost: Codable {
    let cpu: [String]
    let memTotal: Int
    let diskTotal: Int
    let countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case cpu = "CPU"
        case memTotal = "MemTotal"
        case diskTotal = "DiskTotal"
        case countryCode = "CountryCode"
    }
}

struct ServerStatus: Codable {
    let cpu: Double
    let memUsed: Int
    let diskUsed: Int
    let netInTransfer: Int
    let netOutTransfer: Int
    let uptime: Int
    let load15: Double
    
    enum CodingKeys: String, CodingKey {
        case cpu = "CPU"
        case memUsed = "MemUsed"
        case diskUsed = "DiskUsed"
        case netInTransfer = "NetInTransfer"
        case netOutTransfer = "NetOutTransfer"
        case uptime = "Uptime"
        case load15 = "Load15"
    }
}
