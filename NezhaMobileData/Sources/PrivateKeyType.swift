//
//  PrivateKeyType.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/20/24.
//

public enum PrivateKeyType: String, CaseIterable, Identifiable, Codable, Sendable {
    public var id: String {
        return self.rawValue
    }
    
    case ed25519 = "ED25519"
    case p256 = "P256"
    case p384 = "P384"
    case p521 = "P521"
}
