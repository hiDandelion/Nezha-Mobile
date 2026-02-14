//
//  NotificationGroupDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct NotificationGroupDetailView: View {
    @Environment(NMState.self) private var state
    let notificationGroupID: Int64
    var notificationGroup: NotificationGroupData? {
        state.notificationGroups.first(where: { $0.notificationGroupID == notificationGroupID })
    }

    @State private var isShowEditNotificationGroupSheet: Bool = false

    var body: some View {
        if let notificationGroup {
            Form {
                Section {
                    NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(notificationGroup.name)"))
                }

                Section("Members") {
                    if !notificationGroup.notificationIDs.isEmpty {
                        ForEach(notificationGroup.notificationIDs, id: \.self) { notificationID in
                            let notification = state.notifications.first(where: { $0.notificationID == notificationID })
                            Text(notification?.name ?? "#\(notificationID)")
                        }
                    }
                    else {
                        Text("No Members")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(nameCanBeUntitled(notificationGroup.name))
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowEditNotificationGroupSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowEditNotificationGroupSheet, content: {
                EditNotificationGroupView(notificationGroup: notificationGroup)
            })
        }
    }
}
