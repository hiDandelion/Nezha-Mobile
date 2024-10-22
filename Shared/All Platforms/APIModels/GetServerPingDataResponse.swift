//
//  GetServerPingDataResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/20/24.
//

import Foundation

struct GetServerPingDataResponse: Codable {
    let code: Int64
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
