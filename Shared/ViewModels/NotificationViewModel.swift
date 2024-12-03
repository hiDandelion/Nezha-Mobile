//
//  NotificationViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation
import SwiftUI
import Observation

enum NotificationLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@Observable
class NotificationViewModel {
    var loadingState: LoadingState = .idle
    var notifications: [NotificationData] = .init()
    var alertRules: [AlertRuleData] = .init()
    
    func loadData() {
        loadingState = .loading
        Task {
            await getNotification()
            await getAlertRules()
            loadingState = .loaded
        }
    }
    
    func updateSync() async {
        await getNotification()
        await getAlertRules()
    }
    
    func updateAsync() {
        Task {
            await getNotification()
            await getAlertRules()
        }
    }
    
    private func getNotification() async {
        do {
            let response = try await RequestHandler.getNotification()
            DispatchQueue.main.async {
                withAnimation {
                    if let notifications = response.data {
                        self.notifications = notifications.map({
                            NotificationData(id: UUID().uuidString, notificationID: $0.id, name: $0.name, url: $0.url, requestBody: $0.request_body)
                        })
                    }
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    private func getAlertRules() async {
        do {
            let response = try await RequestHandler.getAlertRule()
            DispatchQueue.main.async {
                withAnimation {
                    if let alertRules = response.data {
                        self.alertRules = alertRules.map({ alertRule in
                            AlertRuleData(
                                id: UUID().uuidString,
                                alertRuleID: alertRule.id,
                                notificationGroupID: alertRule.notification_group_id,
                                name: alertRule.name,
                                isEnabled: alertRule.enable,
                                triggerOption: alertRule.trigger_mode,
                                triggerRule: alertRule.rules,
                                taskIDs: alertRule.fail_trigger_tasks,
                                recoverTaskIDs: alertRule.recover_trigger_tasks
                            )
                        })
                    }
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
}
