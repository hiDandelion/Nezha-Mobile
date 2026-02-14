//
//  updateAlertRule.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/2/24.
//

import Foundation
import SwiftyJSON

extension RequestHandler {
    static func updateAlertRule(alertRule: AlertRuleData, name: String) async throws -> UpdateAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule/\(alertRule.alertRuleID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "enable": alertRule.isEnabled,
            "trigger_mode": alertRule.triggerOption,
            "notification_group_id": alertRule.notificationGroupID,
            "rules": alertRule.triggerRule.object,
            "fail_trigger_tasks": alertRule.failureTaskIDs,
            "recover_trigger_tasks": alertRule.recoverTaskIDs
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
    
    static func updateAlertRule(alertRuleID: Int64, name: String, isEnabled: Bool, triggerMode: Int64, notificationGroupID: Int64, rules: [[String: Any]], failTriggerTasks: [Int64], recoverTriggerTasks: [Int64]) async throws -> UpdateAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule/\(alertRuleID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "name": name,
            "enable": isEnabled,
            "trigger_mode": triggerMode,
            "notification_group_id": notificationGroupID,
            "rules": rules,
            "fail_trigger_tasks": failTriggerTasks,
            "recover_trigger_tasks": recoverTriggerTasks
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }

    static func updateAlertRule(alertRule: AlertRuleData, isEnabled: Bool) async throws -> UpdateAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule/\(alertRule.alertRuleID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let token = try await getToken()
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": alertRule.name,
            "enable": isEnabled,
            "trigger_mode": alertRule.triggerOption,
            "notification_group_id": alertRule.notificationGroupID,
            "rules": alertRule.triggerRule.object,
            "fail_trigger_tasks": alertRule.failureTaskIDs,
            "recover_trigger_tasks": alertRule.recoverTaskIDs
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
