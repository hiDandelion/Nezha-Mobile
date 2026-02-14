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
        let site_name: String?
        let language: String?
        let install_host: String
        let tls: Bool?
        let dns_servers: String?
        let real_ip_header: String?
        let ip_change_notification_group_id: Int64?
        let cover: Int64?
        let ignored_ip_notification: String?
        let custom_code: String?
        let custom_code_dashboard: String?
    }
    let success: Bool?
    let error: String?
    let data: SettingData?
}
