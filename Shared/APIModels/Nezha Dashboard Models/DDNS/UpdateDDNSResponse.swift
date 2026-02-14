//
//  UpdateDDNSResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct UpdateDDNSResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
