//
//  AlertDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI

struct AlertDetailView: View {
    @EnvironmentObject var notificationState: NotificationState
    let title: String?
    let content: String?
    
    var body: some View {
        Form {
            Section("Content") {
                Text(content ?? "")
            }
        }
        .navigationTitle(title ?? "")
        .onDisappear {
            notificationState.shouldNavigateToNotificationView = false
        }
    }
}
