//
//  Identity.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/31/24.
//

import Foundation
import SwiftData

enum PrivateKeyType: String, CaseIterable, Identifiable, Codable {
    var id: String {
        return self.rawValue
    }
    
    case ed25519 = "ED25519"
    case p256 = "P256"
    case p384 = "P384"
    case p521 = "P521"
}

@Model
class Identity: Identifiable {
    var id: UUID?
    var name: String?
    var timestamp: Date?
    var username: String?
    var password: String?
    var privateKeyString: String?
    var privateKeyType: PrivateKeyType?
    
    init(name: String, username: String, password: String) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.username = username
        self.password = password
    }
    
    init(name: String, username: String, privateKeyString: String, privateKeyType: PrivateKeyType) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.username = username
        self.privateKeyString = privateKeyString
        self.privateKeyType = privateKeyType
    }
}
