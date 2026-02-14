//
//  DDNSData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct DDNSData: Codable, Identifiable, Hashable {
    var id: String {
        String(ddnsID)
    }
    let ddnsID: Int64
    let name: String
    let provider: String
    let domains: [String]
    let accessID: String
    let accessSecret: String
    let enableIPv4: Bool
    let enableIPv6: Bool
    let maxRetries: Int64
    let webhookURL: String
    let webhookMethod: Int64
    let webhookRequestType: Int64
    let webhookRequestBody: String
    let webhookHeaders: String
}
