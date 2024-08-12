//
//  SocketHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation

enum GetServerDetailError: Error {
    case invalidDashboardConfiguration
    case dashboardAuthenticationFailed
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}

class RequestHandler {
    static func getAllServerDetail() async throws -> GetServerDetailResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/server/details") else {
            throw GetServerDetailError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(dashboardAPIToken, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GetServerDetailResponse.self, from: data)
            
            if response.result != nil {
                return response
            }
            
            if response.code == 403 {
                throw GetServerDetailError.dashboardAuthenticationFailed
            }
            
            throw GetServerDetailError.invalidResponse(response.message)
        } catch let error as GetServerDetailError {
            throw error
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    debugLog("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    debugLog("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    debugLog("Type '\(type)' mismatch: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    debugLog("Value of type '\(type)' not found: \(context.debugDescription)")
                @unknown default:
                    debugLog("Unknown decoding error")
                }
            }
            throw GetServerDetailError.decodingError
        }
    }
    
    static func getServerPingData(serverID: String) async throws -> GetServerPingDataResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/monitor/\(serverID)") else {
            throw GetServerDetailError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(dashboardAPIToken, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GetServerPingDataResponse.self, from: data)
            
            if response.result != nil {
                return response
            }
            
            if response.code == 403 {
                throw GetServerDetailError.dashboardAuthenticationFailed
            }
            
            throw GetServerDetailError.invalidResponse(response.message)
        } catch let error as GetServerDetailError {
            throw error
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    debugLog("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    debugLog("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    debugLog("Type '\(type)' mismatch: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    debugLog("Value of type '\(type)' not found: \(context.debugDescription)")
                @unknown default:
                    debugLog("Unknown decoding error")
                }
            }
            throw GetServerDetailError.decodingError
        }
    }
    
    static func getServerDetail(serverID: String) async throws -> GetServerDetailResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/server/details?id=\(serverID)") else {
            throw GetServerDetailError.invalidDashboardConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(dashboardAPIToken, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GetServerDetailResponse.self, from: data)
            
            if response.result != nil {
                return response
            }
            
            if response.code == 403 {
                throw GetServerDetailError.dashboardAuthenticationFailed
            }
            
            throw GetServerDetailError.invalidResponse(response.message)
        } catch let error as GetServerDetailError {
            throw error
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    debugLog("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    debugLog("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    debugLog("Type '\(type)' mismatch: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    debugLog("Value of type '\(type)' not found: \(context.debugDescription)")
                @unknown default:
                    debugLog("Unknown decoding error")
                }
            }
            throw GetServerDetailError.decodingError
        }
    }
}
