//
//  NotificationGroupNotificationListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import SwiftUI

struct NotificationGroupNotificationListView: View {
    @Environment(\.editMode) private var editMode
    @Environment(NMState.self) private var state
    let notificationGroup: NotificationGroup
    var notificationsInGroup: [NotificationData] {
        state.notifications.filter {
            notificationGroup.notificationIDs.contains($0.notificationID)
        }
    }
    @Binding var selectedNotificationIDs: Set<Int64>

    var body: some View {
        if (!notificationGroup.notificationIDs.isEmpty && editMode?.wrappedValue == .inactive) || (!state.notifications.isEmpty && editMode?.wrappedValue == .active) {
            List(selection: $selectedNotificationIDs) {
                if editMode?.wrappedValue == .inactive {
                    ForEach(notificationsInGroup) { notification in
                        notificationLabel(notification: notification)
                            .tag(notification.notificationID)
                    }
                }
                if editMode?.wrappedValue == .active {
                    ForEach(state.notifications) { notification in
                        notificationLabel(notification: notification)
                            .tag(notification.notificationID)
                    }
                }
            }
        }
        else {
            ContentUnavailableView("No Notification Method", systemImage: "bell.slash")
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
}
