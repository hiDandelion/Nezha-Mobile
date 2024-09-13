//
//  AlertListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/9/24.
//

import SwiftUI
import SwiftData

struct AlertListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TabBarState.self) var tabBarState
    @EnvironmentObject var notificationState: NotificationState
    @Query private var serverAlerts: [ServerAlert]
    
    var body: some View {
        NavigationStack {
            Group {
                if true, !serverAlerts.isEmpty {
                    List {
                        ForEach(serverAlerts) { serverAlert in
                            NavigationLink(destination: AlertDetailView(title: serverAlert.title, content: serverAlert.content)) {
                                VStack(alignment: .leading) {
                                    Text(serverAlert.title ?? "Untitled")
                                    HStack {
                                        Text(serverAlert.timestamp!, style: .date)
                                        Text(serverAlert.timestamp!, style: .time)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(serverAlert)
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
                AlertDetailView(title: notificationState.notificationData?.title, content: notificationState.notificationData?.body)
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
