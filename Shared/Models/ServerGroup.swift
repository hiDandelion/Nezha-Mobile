//
//  ServerGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

struct ServerGroup: Codable, Identifiable, Hashable {
    var id: String {
        String(serverGroupID)
    }
    let serverGroupID: Int64
    let name: String
    let serverIDs: [Int64]
}
