//
//  GetServerConfigResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct GetServerConfigResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: String?
}
