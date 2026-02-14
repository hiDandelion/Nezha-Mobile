//
//  NotificationListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct NotificationListView: View {
    @Environment(NMState.self) private var state
    @AppStorage(NMCore.NMPushNotificationsToken, store: NMCore.userDefaults) private var pushNotificationsToken: String = ""
    var isThisDeviceSetUpAsRecipient: Bool {
        pushNotificationsToken != "" && state.notifications.first(where: { $0.requestBody.contains(pushNotificationsToken) }) != nil
    }
    @State private var isEnrolling: Bool = false
    
    @State private var isShowRenameNotificationAlert: Bool = false
    @State private var notificationToRename: NotificationData?
    @State private var newNameOfNotification: String = ""
    
    @State private var isShowRenameAlertRuleAlert: Bool = false
    @State private var alertRuleToRename: AlertRuleData?
    @State private var newNameOfAlertRule: String = ""
    @State private var isShowAddAlertRuleSheet: Bool = false

    @State private var isShowAddNotificationGroupAlert: Bool = false
    @State private var nameOfNewNotificationGroup: String = ""
    @State private var isAddingNotificationGroup: Bool = false
    @State private var isShowRenameNotificationGroupAlert: Bool = false
    @State private var notificationGroupToRename: NotificationGroupData?
    @State private var newNameOfNotificationGroup: String = ""
    
    var body: some View {
        Form {
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
#if os(iOS) || os(visionOS)
                                        let _ = try await RequestHandler.addNotification(name: UIDevice.current.name, pushNotificationsToken: pushNotificationsToken)
#endif
#if os(macOS)
                                        let _ = try await RequestHandler.addNotification(name: ProcessInfo.processInfo.hostName, pushNotificationsToken: pushNotificationsToken)
#endif
                                        await state.refreshNotifications()
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
#if os(iOS) || os(visionOS)
                        UIPasteboard.general.string = pushNotificationsToken
#endif
#if os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(pushNotificationsToken, forType: .string)
#endif
                    }
                }
                else {
                    Text("Push Notifications Not Available")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Notification Methods") {
                if !state.notifications.isEmpty {
                    ForEach(state.notifications) { notification in
                        notificationLabel(notification: notification)
                            .renamableAndDeletable {
                                showRenameNotificationAlert(notification: notification)
                            } deleteAction: {
                                deleteNotification(notification: notification)
                            }
                    }
                }
                else {
                    Text("No Notification Method")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                if !state.notificationGroups.isEmpty {
                    ForEach(state.notificationGroups) { notificationGroup in
                        NavigationLink(value: notificationGroup) {
                            notificationGroupLabel(notificationGroup: notificationGroup)
                        }
                        .renamableAndDeletable {
                            showRenameNotificationGroupAlert(notificationGroup: notificationGroup)
                        } deleteAction: {
                            deleteNotificationGroup(notificationGroup: notificationGroup)
                        }
                    }
                }
                else {
                    Text("No Notification Group")
                        .foregroundStyle(.secondary)
                }
            } header: {
                HStack {
                    Text("Notification Groups")
                    Spacer()
                    if !isAddingNotificationGroup {
                        Button {
                            isShowAddNotificationGroupAlert = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            
            Section {
                if !state.alertRules.isEmpty {
                    ForEach(state.alertRules) { alertRule in
                        NavigationLink(value: alertRule) {
                            alertRuleLabel(alertRule: alertRule)
                        }
                        .renamableAndDeletable {
                            showRenameAlertRuleAlert(alertRule: alertRule)
                        } deleteAction: {
                            deleteAlertRule(alertRule: alertRule)
                        }
                    }
                }
                else {
                    Text("No Alert Rule")
                        .foregroundStyle(.secondary)
                }
            } header: {
                HStack {
                    Text("Alert Rules")
                    Spacer()
                    Button {
                        isShowAddAlertRuleSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .loadingState(loadingState: state.notificationLoadingState, retryAction: {
            state.loadNotifications()
        })
        .navigationTitle("Notifications")
        .onAppear {
            if state.notificationLoadingState == .idle {
                state.loadNotifications()
            }
            if state.notificationGroupLoadingState == .idle {
                state.loadNotificationGroups()
            }
        }
        .alert("Rename Notification Method", isPresented: $isShowRenameNotificationAlert) {
            TextField("Name", text: $newNameOfNotification)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameNotification(notification: notificationToRename!, name: newNameOfNotification)
            }
        } message: {
            Text("Enter a new name for the notification method.")
        }
        .alert("Rename Alert Rule", isPresented: $isShowRenameAlertRuleAlert) {
            TextField("Name", text: $newNameOfAlertRule)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameAlertRule(alertRule: alertRuleToRename!, name: newNameOfAlertRule)
            }
        } message: {
            Text("Enter a new name for the alert rule.")
        }
        .alert("Add Notification Group", isPresented: $isShowAddNotificationGroupAlert) {
            TextField("Name", text: $nameOfNewNotificationGroup)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addNotificationGroup()
            }
        } message: {
            Text("Enter a name for the new notification group.")
        }
        .sheet(isPresented: $isShowAddAlertRuleSheet) {
            EditAlertRuleView(alertRule: nil)
        }
        .alert("Rename Notification Group", isPresented: $isShowRenameNotificationGroupAlert) {
            TextField("Name", text: $newNameOfNotificationGroup)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameNotificationGroup(notificationGroup: notificationGroupToRename!)
            }
        } message: {
            Text("Enter a new name for the notification group.")
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
            HStack(spacing: 6) {
                Text(nameCanBeUntitled(alertRule.name))
                if !alertRule.isEnabled {
                    Text("Disabled")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.secondary.opacity(0.2), in: .capsule)
                }
            }
            if let ruleCount = alertRule.triggerRule.array?.count {
                Text("\(ruleCount) rule(s)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
    }
    
    private func deleteNotification(notification: NotificationData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteNotification(notifications: [notification])
                await state.refreshNotifications()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
    
    private func showRenameNotificationAlert(notification: NotificationData) {
        notificationToRename = notification
        newNameOfNotification = notification.name
        isShowRenameNotificationAlert = true
    }
    
    private func renameNotification(notification: NotificationData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateNotification(notification: notification, name: name)
                await state.refreshNotifications()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
    
    private func deleteAlertRule(alertRule: AlertRuleData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteAlertRule(alertRules: [alertRule])
                await state.refreshAlertRules()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
    
    private func showRenameAlertRuleAlert(alertRule: AlertRuleData) {
        alertRuleToRename = alertRule
        newNameOfAlertRule = alertRule.name
        isShowRenameAlertRuleAlert = true
    }
    
    private func renameAlertRule(alertRule: AlertRuleData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateAlertRule(alertRule: alertRule, name: name)
                await state.refreshAlertRules()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func notificationGroupLabel(notificationGroup: NotificationGroupData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(notificationGroup.name))
            Text("\(notificationGroup.notificationIDs.count) notification(s)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }

    private func addNotificationGroup() {
        isAddingNotificationGroup = true
        Task {
            do {
                let _ = try await RequestHandler.addNotificationGroup(name: nameOfNewNotificationGroup, notifications: [])
                await state.refreshNotificationGroups()
                isAddingNotificationGroup = false
                nameOfNewNotificationGroup = ""
            } catch {
                isAddingNotificationGroup = false
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func deleteNotificationGroup(notificationGroup: NotificationGroupData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteNotificationGroup(notificationGroups: [notificationGroup])
                await state.refreshNotificationGroups()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func showRenameNotificationGroupAlert(notificationGroup: NotificationGroupData) {
        notificationGroupToRename = notificationGroup
        newNameOfNotificationGroup = notificationGroup.name
        isShowRenameNotificationGroupAlert = true
    }

    private func renameNotificationGroup(notificationGroup: NotificationGroupData) {
        Task {
            do {
                let _ = try await RequestHandler.updateNotificationGroup(notificationGroup: notificationGroupToRename!, name: newNameOfNotificationGroup)
                await state.refreshNotificationGroups()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
