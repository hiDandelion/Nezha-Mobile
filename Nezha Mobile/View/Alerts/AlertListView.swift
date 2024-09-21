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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.createDataHandler) private var createDataHandler
    @EnvironmentObject var notificationState: NotificationState
    @Environment(TabBarState.self) var tabBarState
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    @State private var isAlertRetrievalFailed: Bool = false
    @State private var isShowRetryAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !serverAlerts.isEmpty {
                    List {
                        ForEach(serverAlerts) { serverAlert in
                            NavigationLink(destination: AlertDetailView(time: serverAlert.timestamp, title: serverAlert.title, content: serverAlert.content)) {
                                VStack(alignment: .leading) {
                                    Text(serverAlert.title ?? "Untitled")
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
                    .contentMargins(.bottom, 50)
                    .navigationTitle("Alerts")
                }
                else {
                    ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
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
}
