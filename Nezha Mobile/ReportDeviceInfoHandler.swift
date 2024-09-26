//
//  ReportDeviceInfoHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/26/24.
//

import Foundation

enum ReportDeviceInfoError: Error {
    case invalidAgentConfiguration
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}

struct ReportDeviceInfoResponse: Codable {
    let success: Bool
    let error: String?
}

extension RequestHandler {
    static func reportDeviceHost(identifier: String, systemVersion: String, diskTotal: Int64, bootTime: Int64) async throws -> ReportDeviceInfoResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardGRPCLink = userDefaults.string(forKey: "NMDashboardGRPCLink"),
              let dashboardGRPCPort = userDefaults.string(forKey: "NMDashboardGRPCPort"),
              let agentSecret = userDefaults.string(forKey: "NMAgentSecret"),
              let url = URL(string: "https://nezha-mobile-grpc-bridge.argsment.com/api/report-host") else {
            throw ReportDeviceInfoError.invalidAgentConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "server": "\(dashboardGRPCLink):\(dashboardGRPCPort)",
            "secret": agentSecret,
            "identifier": identifier,
            "systemVersion": systemVersion,
            "diskTotal": diskTotal,
            "bootTime": bootTime * 1000
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ReportDeviceInfoResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
    
    static func reportDeviceStatus(memoryUsed: Int64, diskUsed: Int64, uptime: Int64) async throws -> ReportDeviceInfoResponse {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardGRPCLink = userDefaults.string(forKey: "NMDashboardGRPCLink"),
              let dashboardGRPCPort = userDefaults.string(forKey: "NMDashboardGRPCPort"),
              let agentSecret = userDefaults.string(forKey: "NMAgentSecret"),
              let url = URL(string: "https://nezha-mobile-grpc-bridge.argsment.com/api/report-status") else {
            throw ReportDeviceInfoError.invalidAgentConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "server": "\(dashboardGRPCLink):\(dashboardGRPCPort)",
            "secret": agentSecret,
            "memoryUsed": memoryUsed,
            "diskUsed": diskUsed,
            "uptime": uptime
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ReportDeviceInfoResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
