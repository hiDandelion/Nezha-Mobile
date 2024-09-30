//
//  NezhaDashboardHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/29/24.
//

import Foundation

enum NezhaDashboardError: Error {
    case invalidDashboardConfiguration
    case dashboardAuthenticationFailed
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}

extension RequestHandler {
    static func getAllServerDetail() async throws -> GetServerDetailResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/server/details") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
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
                throw NezhaDashboardError.dashboardAuthenticationFailed
            }
            
            throw NezhaDashboardError.invalidResponse(response.message)
        } catch let error as NezhaDashboardError {
            throw error
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
    
    static func getServerDetail(serverID: String) async throws -> GetServerDetailResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/server/details?id=\(serverID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
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
                throw NezhaDashboardError.dashboardAuthenticationFailed
            }
            
            throw NezhaDashboardError.invalidResponse(response.message)
        } catch let error as NezhaDashboardError {
            throw error
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
    
    static func getServerPingData(serverID: String) async throws -> GetServerPingDataResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/monitor/\(serverID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
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
                throw NezhaDashboardError.dashboardAuthenticationFailed
            }
            
            throw NezhaDashboardError.invalidResponse(response.message)
        } catch let error as NezhaDashboardError {
            throw error
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
