//
//  ServerAlertHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/12/24.
//

import Foundation

enum GetServerAlertError: Error {
    case invalidDashboardConfiguration
    case dashboardAuthenticationFailed
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}

struct GetServerAlertResponse: Codable {
    let data: [ServerAlertItem]
}

struct ServerAlertItem: Codable {
    let timestamp: Date
    let title: String?
    let body: String?
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case title
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let milliseconds = try container.decode(Double.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: milliseconds / 1000)
        
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timestamp.timeIntervalSince1970 * 1000, forKey: .timestamp)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
    }
}

extension RequestHandler {
    static func getServerAlert(deviceToken: String) async throws -> GetServerAlertResponse {
        let url = URL(string: "https://nezha-mobile-apns.argsment.com/api/retrieve-alerts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["iOSDeviceToken": deviceToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GetServerAlertResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
