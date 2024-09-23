//
//  ServerAlert.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/10/24.
//

import Foundation
import SwiftData

public typealias ServerAlert = SchemaV1.Alert

extension SchemaV1 {
    @Model
    public final class Alert: Identifiable {
        public var id: UUID?
        public var timestamp: Date?
        public var title: String?
        public var content: String?
        
        public init(timestamp: Date, title: String?, content: String?) {
            self.id = UUID()
            self.timestamp = timestamp
            self.title = title
            self.content = content
        }
    }
}
