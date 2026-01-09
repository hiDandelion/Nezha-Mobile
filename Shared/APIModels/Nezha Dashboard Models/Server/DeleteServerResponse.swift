//
//  DeleteServerResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/9/26.
//

import Foundation

struct DeleteServerResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
