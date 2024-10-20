//
//  OpenSSHKey.swift
//  Sapient Shell
//
//  Created by Junhui Lou on 8/22/24.
//

import Foundation
import CryptoKit

enum DecodeKeyError: Error {
    case invalidKeyFormat
    case decodingError
}

func decodeOpenSSHED25519KeyToCurve25519(openSSHED25519Key: String) throws -> Curve25519.Signing.PrivateKey {
    let lines = openSSHED25519Key.components(separatedBy: "\n").filter { line in
        !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END") && !line.isEmpty
    }
    
    let base64EncodedKey = lines.joined()
    guard let keyData = Data(base64Encoded: base64EncodedKey) else {
        throw DecodeKeyError.decodingError
    }
    
    let keyDataBytes = [UInt8](keyData)
    
    if keyDataBytes.count < 194 {
        throw DecodeKeyError.invalidKeyFormat
    }
    
    return try Curve25519.Signing.PrivateKey(rawRepresentation: Array(keyDataBytes[161..<193]))
}

func decodeP256Key(p256Key: String) throws -> P256.Signing.PrivateKey {
    let lines = p256Key.components(separatedBy: "\n").filter { line in
        !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END") && !line.isEmpty
    }
    
    let base64EncodedKey = lines.joined()
    guard let derData = Data(base64Encoded: base64EncodedKey) else {
        throw DecodeKeyError.decodingError
    }
    
    return try P256.Signing.PrivateKey(derRepresentation: derData)
}

func decodeP384Key(p384Key: String) throws -> P384.Signing.PrivateKey {
    let lines = p384Key.components(separatedBy: "\n").filter { line in
        !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END") && !line.isEmpty
    }
    
    let base64EncodedKey = lines.joined()
    guard let derData = Data(base64Encoded: base64EncodedKey) else {
        throw DecodeKeyError.decodingError
    }
    
    return try P384.Signing.PrivateKey(derRepresentation: derData)
}

func decodeP521Key(p521Key: String) throws -> P521.Signing.PrivateKey {
    let lines = p521Key.components(separatedBy: "\n").filter { line in
        !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END") && !line.isEmpty
    }
    
    let base64EncodedKey = lines.joined()
    guard let derData = Data(base64Encoded: base64EncodedKey) else {
        throw DecodeKeyError.decodingError
    }
    
    return try P521.Signing.PrivateKey(derRepresentation: derData)
}
