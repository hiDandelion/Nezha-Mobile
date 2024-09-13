//
//  AlertListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/9/24.
//

import SwiftUI
import SwiftData

struct AlertListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(TabBarState.self) var tabBarState
    @EnvironmentObject var notificationState: NotificationState
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    
    var body: some View {
        NavigationStack {
            Group {
                if !serverAlerts.isEmpty {
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
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    getServerAlert()
                }
            }
            .onAppear {
                withAnimation {
                    tabBarState.isAlertsViewVisible = true
                }
                
                getServerAlert()
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isAlertsViewVisible = false
                }
            }
        }
    }
    
    private func getServerAlert() {
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        let pushNotificationsToken = userDefaults.string(forKey: "NMPushNotificationsToken")!
        if pushNotificationsToken != "" {
            Task {
                let getServerAlertResponse = try? await RequestHandler.getServerAlert(deviceToken: pushNotificationsToken)
                if let getServerAlertResponse {
                    for serverAlertItem in getServerAlertResponse.data {
                        let newServerAlert = ServerAlert(timestamp: serverAlertItem.timestamp, title: serverAlertItem.title, content: serverAlertItem.body)
                        modelContext.insert(newServerAlert)
                    }
                }
            }
        }
    }
}
