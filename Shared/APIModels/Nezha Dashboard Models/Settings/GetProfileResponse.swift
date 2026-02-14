//
//  GetProfileResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/2/26.
//

import Foundation

struct GetProfileResponse: Codable, NezhaDashboardBaseResponse {
    struct ProfileData: Codable {
        let agent_secret: String
        let username: String?
    }
    let success: Bool?
    let error: String?
    let data: ProfileData?
}
