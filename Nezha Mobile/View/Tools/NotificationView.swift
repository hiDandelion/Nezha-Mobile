//
//  NotificationView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct NotificationView: View {
    @Environment(NotificationViewModel.self) private var notificationViewModel
    @AppStorage(NMCore.NMPushNotificationsToken, store: NMCore.userDefaults) private var pushNotificationsToken: String = ""
    var isThisDeviceSetUpAsRecipient: Bool {
        pushNotificationsToken != "" && notificationViewModel.notifications.first(where: { $0.requestBody.contains(pushNotificationsToken) }) != nil
    }
    @State private var isEnrolling: Bool = false
    @State private var idOfAlertRuleToggling: String?
    
    var body: some View {
        @Bindable var notificationViewModel = notificationViewModel
        List {
            Section {
                if pushNotificationsToken != "" {
                    HStack {
                        if isThisDeviceSetUpAsRecipient {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("This device is enrolled")
                        }
                        else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                            Text("This device is not enrolled")
                        }
                    }
                    if !isThisDeviceSetUpAsRecipient {
                        if !isEnrolling {
                            Button("Enroll Automatically") {
                                isEnrolling = true
                                Task {
                                    do {
                                        let _ = try await RequestHandler.addNotification(name: UIDevice.current.name, pushNotificationsToken: pushNotificationsToken)
                                        await notificationViewModel.refreshNotificationSync()
                                        isEnrolling = false
                                    } catch {
                                        isEnrolling = false
    #if DEBUG
                                        let _ = NMCore.debugLog(error)
    #endif
                                    }
                                }
                            }
                        }
                        else {
                            ProgressView()
                        }
                    }
                    Button("Copy Push Notifications Token") {
                        UIPasteboard.general.string = pushNotificationsToken
                    }
                }
                else {
                    Text("Push Notifications Not Available")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Notification Methods") {
                if !notificationViewModel.notifications.isEmpty {
                    ForEach(notificationViewModel.notifications) { notification in
                        notificationLabel(notification: notification)
                    }
                }
                else {
                    Text("No Notification Method")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Alert Rules") {
                if !notificationViewModel.alertRules.isEmpty {
                    ForEach(notificationViewModel.alertRules) { alertRule in
                        if idOfAlertRuleToggling != alertRule.id {
                            Toggle(isOn: Binding(
                                get: {
                                    alertRule.isEnabled
                                },
                                set: { newValue in
                                    idOfAlertRuleToggling = alertRule.id
                                    Task {
                                        do {
                                            let _ = try await RequestHandler.updateAlertRule(alertRule: alertRule, isEnabled: newValue)
                                            await notificationViewModel.refreshAlertRuleSync()
                                            idOfAlertRuleToggling = nil
                                        } catch {
                                            idOfAlertRuleToggling = nil
    #if DEBUG
                                            let _ = NMCore.debugLog(error)
    #endif
                                        }
                                    }
                                })
                            ) {
                                alertRuleLabel(alertRule: alertRule)
                            }
                        }
                        else {
                            HStack {
                                alertRuleLabel(alertRule: alertRule)
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
                else {
                    Text("No Alert Rule")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .canInLoadingStateModifier(loadingState: $notificationViewModel.loadingState, retryAction: {
            notificationViewModel.loadData()
        })
        .navigationTitle("Notifications")
        .onAppear {
            if notificationViewModel.loadingState == .idle {
                notificationViewModel.loadData()
            }
        }
    }
    
    private func notificationLabel(notification: NotificationData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(notification.name))
            Text(notification.url)
                .font(.footnote)
                .foregroundStyle(.secondary)
            
        }
        .lineLimit(1)
    }
    
    private func alertRuleLabel(alertRule: AlertRuleData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(alertRule.name))
            Text(alertRule.triggerRule ?? "No Rule")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
        }
        .lineLimit(1)
    }
}
