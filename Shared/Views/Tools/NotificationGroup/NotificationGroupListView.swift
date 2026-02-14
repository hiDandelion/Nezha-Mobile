//
//  NotificationGroupListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct NotificationGroupListView: View {
    @Environment(NMState.self) private var state

    @State private var isShowAddNotificationGroupAlert: Bool = false
    @State private var nameOfNewNotificationGroup: String = ""
    @State private var isAddingNotificationGroup: Bool = false

    @State private var isShowRenameNotificationGroupAlert: Bool = false
    @State private var notificationGroupToRename: NotificationGroupData?
    @State private var newNameOfNotificationGroup: String = ""

    var body: some View {
        List {
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
        }
        .loadingState(loadingState: state.notificationGroupLoadingState) {
            state.loadNotificationGroups()
        }
        .navigationTitle("Notification Groups")
        .toolbar {
            ToolbarItem {
                if !isAddingNotificationGroup {
                    Button {
                        isShowAddNotificationGroupAlert = true
                    } label: {
                        Label("Add Notification Group", systemImage: "plus")
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            if state.notificationGroupLoadingState == .idle {
                state.loadNotificationGroups()
            }
        }
        .alert("Add Notification Group", isPresented: $isShowAddNotificationGroupAlert) {
            TextField("Name", text: $nameOfNewNotificationGroup)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
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
        } message: {
            Text("Enter a name for the new notification group.")
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

    private func notificationGroupLabel(notificationGroup: NotificationGroupData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(notificationGroup.name))
            Text("\(notificationGroup.notificationIDs.count) notification(s)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
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
