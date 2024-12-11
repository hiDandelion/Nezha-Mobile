//
//  MonitorData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

struct MonitorData: Codable, Identifiable, Hashable {
    var id: String {
        String(monitorID)
    }
    let monitorID: Int64
    let serverID: Int64
    let monitorName: String
    let serverName: String
    let dates: [Date]
    let delays: [Double]
}
