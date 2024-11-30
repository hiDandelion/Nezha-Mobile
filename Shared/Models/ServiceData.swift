//
//  ServiceData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

struct ServiceData: Codable, Identifiable, Hashable {
    let id: String
    let monitorID: Int64
    let serverID: Int64
    let monitorName: String
    let serverName: String
    let dates: [Date]
    let delays: [Double]
}
