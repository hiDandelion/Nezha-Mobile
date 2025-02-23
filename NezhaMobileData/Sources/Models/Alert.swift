//
//  ServerAlert.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/10/24.
//

import Foundation
import SwiftData

public typealias ServerAlert = SchemaV2.Alert

extension SchemaV1 {
    @Model
    public final class Alert: Identifiable {
        @Attribute(.unique) public var id: UUID?
        public var timestamp: Date?
        public var title: String?
        public var content: String?
        
        public init(uuid: UUID, timestamp: Date, title: String?, content: String?) {
            self.id = uuid
            self.timestamp = timestamp
            self.title = title
            self.content = content
        }
        
        public init(timestamp: Date, title: String?, content: String?) {
            self.id = UUID()
            self.timestamp = timestamp
            self.title = title
            self.content = content
        }
    }
}

extension SchemaV2 {
    @Model
    public final class Alert: Identifiable {
        @Attribute(.unique) public var id: UUID?
        public var timestamp: Date?
        public var title: String?
        public var content: String?
        
        public init(uuid: UUID, timestamp: Date, title: String?, content: String?) {
            self.id = uuid
            self.timestamp = timestamp
            self.title = title
            self.content = content
        }
        
        public init(timestamp: Date, title: String?, content: String?) {
            self.id = UUID()
            self.timestamp = timestamp
            self.title = title
            self.content = content
        }
    }
}
