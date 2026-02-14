//
//  EditNotificationGroupView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct EditNotificationGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let notificationGroup: NotificationGroupData?

    @State private var isProcessing: Bool = false
    @State private var name: String = ""
    @State private var selectedNotificationIDs: Set<Int64> = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }

                Section("Notifications") {
                    if !state.notifications.isEmpty {
                        ForEach(state.notifications) { notification in
                            Button {
                                if selectedNotificationIDs.contains(notification.notificationID) {
                                    selectedNotificationIDs.remove(notification.notificationID)
                                } else {
                                    selectedNotificationIDs.insert(notification.notificationID)
                                }
                            } label: {
                                HStack {
                                    Text(nameCanBeUntitled(notification.name))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedNotificationIDs.contains(notification.notificationID) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        Text("No Notification Method")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(notificationGroup != nil ? "Edit Notification Group" : "Add Notification Group")
#if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) {
                            dismiss()
                        }
                    }
                    else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if !isProcessing {
                        if #available(iOS 26, macOS 26, visionOS 26, *) {
                            Button("Done", systemImage: "checkmark", role: .confirm) {
                                execute()
                            }
                        }
                        else {
                            Button("Done") {
                                execute()
                            }
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                if let notificationGroup {
                    name = notificationGroup.name
                    selectedNotificationIDs = Set(notificationGroup.notificationIDs)
                }
            }
        }
    }

    private func execute() {
        isProcessing = true
        let notificationIDs = Array(selectedNotificationIDs)
        if let notificationGroup {
            Task {
                do {
                    let _ = try await RequestHandler.updateNotificationGroup(notificationGroup: notificationGroup, name: name, notifications: notificationIDs)
                    await state.refreshNotificationGroups()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
        else {
            Task {
                do {
                    let _ = try await RequestHandler.addNotificationGroup(name: name, notifications: notificationIDs)
                    await state.refreshNotificationGroups()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
    }
}
