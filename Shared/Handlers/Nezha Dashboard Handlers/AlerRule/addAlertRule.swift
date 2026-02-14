//
//  addAlertRule.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

extension RequestHandler {
    static func addAlertRule(name: String, isEnabled: Bool, triggerMode: Int64, notificationGroupID: Int64, rules: [[String: Any]], failTriggerTasks: [Int64], recoverTriggerTasks: [Int64]) async throws -> AddAlertRuleResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/alert-rule") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
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
}
