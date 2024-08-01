//
//  Dashboard.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import SwiftData

@Model
final class Dashboard {
    var id: UUID
    var timestamp: Date
    var name: String
    var link: String
    var ssl: Bool
    
    init(name: String, link: String, ssl: Bool) {
        self.id = UUID()
        self.timestamp = Date()
        self.name = name
        self.link = link
        self.ssl = ssl
    }
}
