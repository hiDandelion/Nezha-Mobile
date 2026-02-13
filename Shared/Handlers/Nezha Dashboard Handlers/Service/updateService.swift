//
//  updateService.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation
import SwiftyJSON

extension RequestHandler {
    static func updateService(service: ServiceData, name: String) async throws -> UpdateServiceResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/service/\(service.serviceID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "type": service.type.rawValue,
            "target": service.target,
            "duration": service.interval,
            "notification_group_id": service.notificationGroupID,
            "cover": service.coverageOption,
            "fail_trigger_tasks": service.failureTaskIDs ?? [],
            "recover_trigger_tasks": service.recoverTaskIDs ?? [],
            "min_latency": service.minimumLatency,
            "max_latency": service.maximumLatency,
            "skip_servers": service.excludeRule.object
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
    
    static func updateService(service: ServiceData, name: String, type: ServiceType, target: String, interval: Int64) async throws -> UpdateServiceResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/service/\(service.serviceID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "type": type.rawValue,
            "target": target,
            "duration": interval,
            "notification_group_id": service.notificationGroupID,
            "cover": service.coverageOption,
            "fail_trigger_tasks": service.failureTaskIDs ?? [],
            "recover_trigger_tasks": service.recoverTaskIDs ?? [],
            "min_latency": service.minimumLatency,
            "max_latency": service.maximumLatency,
            "skip_servers": service.excludeRule.object
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
