//
//  AlertListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/9/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct AlertListView: View {
    @Environment(\.createDataHandler) private var createDataHandler
    @EnvironmentObject var notificationState: NotificationState
    @Environment(TabBarState.self) var tabBarState
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    @State private var isShowingDeleteAllConfirmationDialog: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !serverAlerts.isEmpty {
                    List {
                        ForEach(serverAlerts) { serverAlert in
                            NavigationLink(destination: AlertDetailView(time: serverAlert.timestamp, title: serverAlert.title, content: serverAlert.content)) {
                                VStack(alignment: .leading) {
                                    Text(serverAlert.title ?? "Untitled")
                                        .lineLimit(1)
                                    Text(serverAlert.content ?? "No Content")
                                        .font(.footnote)
                                        .lineLimit(1)
                                    if let timestamp = serverAlert.timestamp {
                                        Text(timestamp.formatted(date: .numeric, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        let createDataHandler = createDataHandler
                                        Task {
                                            if let dataHandler = await createDataHandler() {
                                                _ = try await dataHandler.deleteServerAlert(id: serverAlert.persistentModelID)
                                            }
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Alerts")
                    .toolbar {
#if DEBUG
                        ToolbarItem(placement: .topBarLeading) {
                            addAlertButton
                        }
#endif
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(role: .destructive) {
                                isShowingDeleteAllConfirmationDialog = true
                            } label: {
                                Label("Delete All", systemImage: "trash")
                            }
                            .confirmationDialog(
                                Text("Delete All Alerts"),
                                isPresented: $isShowingDeleteAllConfirmationDialog,
                                actions: {
                                    Button("Delete", role: .destructive) {
                                        let createDataHandler = createDataHandler
                                        Task {
                                            if let dataHandler = await createDataHandler() {
                                                _ = try await dataHandler.deleteAllServerAlerts()
                                            }
                                        }
                                    }
                                },
                                message: {
                                    Text("All alerts will be deleted. Are you sure?")
                                }
                            )
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 50)
                    }
                }
                else {
#if DEBUG
                    addAlertButton
#else
                    ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
#endif
                }
            }
            .navigationDestination(isPresented: $notificationState.shouldNavigateToNotificationView) {
                AlertDetailView(time: nil, title: notificationState.notificationData?.title, content: notificationState.notificationData?.body)
            }
            .onAppear {
                withAnimation {
                    tabBarState.isAlertsViewVisible = true
                }
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isAlertsViewVisible = false
                }
            }
        }
    }
    
#if DEBUG
    private var addAlertButton: some View {
        Button {
            let createDataHandler = createDataHandler
            Task {
                if let dataHandler = await createDataHandler() {
                    _ = try await dataHandler.newServerAlert(uuid: UUID(), timestamp: Date(), title: "New Alert", content: "Alert Content")
                }
            }
        } label: {
            Label("Add Alert", systemImage: "plus")
        }
    }
#endif
}
