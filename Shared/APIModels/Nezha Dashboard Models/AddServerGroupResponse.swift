//
//  AddServerGroupResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation

struct AddServerGroupResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
