//
//  NotificationGroupDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import SwiftUI

struct NotificationGroupDetailView: View {
    @Environment(NMState.self) private var state
    let notificationGroupID: Int64
    var notificationGroup: NotificationGroup? {
        state.notificationGroups.first(where: { $0.notificationGroupID == notificationGroupID })
    }
    @State private var editMode: EditMode = .inactive
    @State private var selectedNotificationIDs: Set<Int64> = .init()
    @State private var isUpdatingNotificationGroup: Bool = false

    var body: some View {
        if let notificationGroup = notificationGroup {
            NotificationGroupNotificationListView(notificationGroup: notificationGroup, selectedNotificationIDs: $selectedNotificationIDs)
                .navigationTitle(nameCanBeUntitled(notificationGroup.name))
                .toolbar {
                    ToolbarItem {
                        editButton(notificationGroup: notificationGroup)
                    }
                }
                .environment(\.editMode, $editMode)
                .onChange(of: editMode) {
                    if editMode == .active {
                        selectedNotificationIDs = Set(notificationGroup.notificationIDs)
                    }
                }
        }
    }

    private func editButton(notificationGroup: NotificationGroup) -> some View {
        Group {
            if editMode == .inactive {
                Button {
                    withAnimation {
                        editMode = .active
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            if editMode == .active {
                if !isUpdatingNotificationGroup {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Done", systemImage: "checkmark", role: .confirm) {
                            execute(notificationGroup: notificationGroup)
                        }
                    }
                    else {
                        Button("Done") {
                            execute(notificationGroup: notificationGroup)
                        }
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
    }

    private func execute(notificationGroup: NotificationGroup) {
        let selectedNotificationIDArray = Array(selectedNotificationIDs)
        guard Set(selectedNotificationIDArray) != Set(notificationGroup.notificationIDs) else {
            withAnimation {
                editMode = .inactive
            }
            return
        }
        isUpdatingNotificationGroup = true
        Task {
            do {
                let _ = try await RequestHandler.updateNotificationGroup(notificationGroup: notificationGroup, notificationIDs: selectedNotificationIDArray)
                await state.refreshNotificationGroups()
                isUpdatingNotificationGroup = false
                withAnimation {
                    editMode = .inactive
                }
            } catch {
                isUpdatingNotificationGroup = false
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
