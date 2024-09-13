//
//  ServerAlert.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/10/24.
//

import Foundation
import SwiftData

@Model
class ServerAlert: Identifiable {
    var id: UUID?
    var timestamp: Date?
    var title: String?
    var content: String?
    
    init(timestamp: Date, title: String?, content: String?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.title = title
        self.content = content
    }
}
