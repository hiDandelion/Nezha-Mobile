//
//  updateAlertRule.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/2/24.
//

import Foundation

extension RequestHandler {
    static func updateAlertRule(alertRule: AlertRuleData, isEnabled: Bool) async throws -> UpdateAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule/\(alertRule.alertRuleID)") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let loginResponse = try await login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = "PATCH"
        request.setValue("nz-jwt=\(token)", forHTTPHeaderField: "Cookie")
        
        let body: [String: Any] = [
            "enable": alertRule.isEnabled,
            "trigger_mode": alertRule.triggerOption,
            "notification_group_id": alertRule.notificationGroupID,
            "rules": alertRule.triggerRules.map({
                GetAlertRuleResponse.Rule(
                    type: $0.type,
                    duration: $0.duration,
                    min: $0.min,
                    max: $0.max,
                    cover: $0.coverageOption
                )
            }),
            "fail_trigger_tasks": alertRule.taskIDs,
            "recover_trigger_tasks": alertRule.recoverTaskIDs
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try decodeNezhaDashboardResponse(data: data)
    }
}
