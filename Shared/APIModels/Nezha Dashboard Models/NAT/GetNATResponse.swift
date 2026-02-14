//
//  GetNATResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct GetNATResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [NAT]?

    struct NAT: Codable {
        let id: Int64
        let name: String
        let server_id: Int64
        let host: String?
        let domain: String?
        let enabled: Bool?
    }
}
