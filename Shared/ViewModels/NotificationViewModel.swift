//
//  NotificationViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation
import SwiftUI
import Observation

@Observable
class NotificationViewModel {
    var loadingState: LoadingState = .idle
    var notifications: [NotificationData] = .init()
    var alertRules: [AlertRuleData] = .init()
    
    func loadData() {
        loadingState = .loading
        Task {
            do {
                try await getNotification()
                try await getAlertRule()
                loadingState = .loaded
            }
            catch {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }
    
    func refresh() async {
        try? await getNotification()
        try? await getAlertRule()
    }
    
    func refreshNotification() async {
        try? await getNotification()
    }
    
    func refreshAlertRule() async {
        try? await getAlertRule()
    }
    
    private func getNotification() async throws {
        let response = try await RequestHandler.getNotification()
        withAnimation {
            self.notifications = response.data?.map({
                NotificationData(
                    notificationID: $0.id,
                    name: $0.name,
                    url: $0.url,
                    requestMethod: $0.request_method,
                    requestType: $0.request_type,
                    requestHeader: $0.request_header,
                    requestBody: $0.request_body,
                    isVerifyTLS: $0.verify_tls
                )
            }) ?? []
        }
    }
    
    private func getAlertRule() async throws {
        let response = try await RequestHandler.getAlertRule()
        withAnimation {
            alertRules = response.data?.map({ alertRule in
                AlertRuleData(
                    alertRuleID: alertRule.id,
                    notificationGroupID: alertRule.notification_group_id,
                    name: alertRule.name,
                    isEnabled: alertRule.enable,
                    triggerOption: alertRule.trigger_mode,
                    triggerRule: alertRule.rules,
                    failureTaskIDs: alertRule.fail_trigger_tasks,
                    recoverTaskIDs: alertRule.recover_trigger_tasks
                )
            }) ?? []
        }
    }
}
