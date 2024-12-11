//
//  AddServiceResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation

struct AddServiceResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
}
