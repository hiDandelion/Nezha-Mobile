//
//  Identity.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/31/24.
//

import Foundation
import SwiftData

@Model
public final class Identity: Identifiable {
    public var id: UUID?
    public var timestamp: Date?
    public var name: String?
    public var username: String?
    public var password: String?
    public var privateKeyString: String?
    public var privateKeyType: PrivateKeyType?
    
    public init(name: String, username: String, password: String) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.username = username
        self.password = password
    }
    
    public init(name: String, username: String, privateKeyString: String, privateKeyType: PrivateKeyType) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.username = username
        self.privateKeyString = privateKeyString
        self.privateKeyType = privateKeyType
    }
}
