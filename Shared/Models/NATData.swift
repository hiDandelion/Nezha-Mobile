//
//  NATData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct NATData: Codable, Identifiable, Hashable {
    var id: String {
        String(natID)
    }
    let natID: Int64
    let name: String
    let serverID: Int64
    let host: String
    let domain: String
    let isEnabled: Bool
}
