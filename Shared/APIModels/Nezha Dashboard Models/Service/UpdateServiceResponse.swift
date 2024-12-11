//
//  UpdateServiceResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation

struct UpdateServiceResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
