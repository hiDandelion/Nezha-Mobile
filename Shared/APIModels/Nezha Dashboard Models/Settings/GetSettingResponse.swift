//
//  GetSettingResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/2/26.
//

import Foundation

struct GetSettingResponse: Codable, NezhaDashboardBaseResponse {
    struct SettingData: Codable {
        let config: SettingConfig
    }
    struct SettingConfig: Codable {
        let install_host: String
    }
    let success: Bool?
    let error: String?
    let data: SettingData?
}
