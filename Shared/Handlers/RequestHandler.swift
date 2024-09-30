//
//  SocketHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation

class RequestHandler {
    static func handleDecodingError(error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            _ = debugLog("Data corrupted - \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            _ = debugLog("Key '\(key)' not found - \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            _ = debugLog("Type '\(type)' mismatch - \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            _ = debugLog("Value of type '\(type)' not found - \(context.debugDescription)")
        @unknown default:
            _ = debugLog("Unknown decoding error")
        }
    }
}
