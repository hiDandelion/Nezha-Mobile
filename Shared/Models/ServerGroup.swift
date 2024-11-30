//
//  ServerGroup.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

struct ServerGroup: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let serverIDs: [Int64]
}
