//
//  NotificationDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI

struct NotificationDetailView: View {
    @EnvironmentObject var notificationState: NotificationState
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    Text("\(notificationState.notificationData?.body ?? "")")
                }
            }
            .navigationTitle(notificationState.notificationData?.title ?? "")
        }
        .onDisappear {
            notificationState.shouldNavigateToNotificationView = false
        }
    }
}
