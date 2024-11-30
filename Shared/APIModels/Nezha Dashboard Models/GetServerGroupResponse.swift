//
//  GetServerGroupResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

struct GetServerGroupResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [ServerGroup]?
    
    struct ServerGroup: Codable {
        let group: Group
        let servers: [Int64]?
        
        struct Group: Codable {
            let name: String
        }
    }
}
