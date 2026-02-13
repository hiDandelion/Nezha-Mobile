//
//  TokenManager.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/13/26.
//

import Foundation

actor TokenManager {
    static let shared = TokenManager()

    private var cachedToken: String?
    private var tokenExpiration: Date?

    /// Returns a valid token — cached if still fresh, or fetches a new one.
    func getToken() async throws -> String {
        if let cachedToken, let tokenExpiration, Date() < tokenExpiration {
            return cachedToken
        }

        let loginResponse = try await RequestHandler.login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }

        cachedToken = token

        if let expiration = jwtExpiration(from: token) {
            // Refresh 60 seconds before actual expiry
            tokenExpiration = expiration.addingTimeInterval(-60)
        } else {
            // Fallback: assume 30-minute TTL
            tokenExpiration = Date().addingTimeInterval(30 * 60)
        }

        return token
    }

    /// Clears the cached token, forcing a fresh login on the next request.
    func invalidateToken() {
        cachedToken = nil
        tokenExpiration = nil
    }

    /// Decodes a JWT payload to extract the `exp` claim.
    private func jwtExpiration(from token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var base64 = String(segments[1])
        // Pad to multiple of 4 for base64 decoding
        let remainder = base64.count % 4
        if remainder != 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        guard let exp = json["exp"] as? TimeInterval else { return nil }

        return Date(timeIntervalSince1970: exp)
    }
}
