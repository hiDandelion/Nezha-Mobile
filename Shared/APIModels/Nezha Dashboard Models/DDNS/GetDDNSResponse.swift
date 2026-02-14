//
//  GetDDNSResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct GetDDNSResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: [DDNS]?

    struct DDNS: Codable {
        let id: Int64
        let name: String?
        let provider: String?
        let domains: [String]?
        let access_id: String?
        let access_secret: String?
        let enable_ipv4: Bool?
        let enable_ipv6: Bool?
        let max_retries: Int64?
        let webhook_url: String?
        let webhook_method: Int64?
        let webhook_request_type: Int64?
        let webhook_request_body: String?
        let webhook_headers: String?
    }
}
