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
        NavigationStack {
            Form {
                Section("Content") {
                    Text(content ?? "")
                }
            }
            .contentMargins(.bottom, 50)
            .navigationTitle(title ?? "")
        }
        .onDisappear {
            notificationState.shouldNavigateToNotificationView = false
        }
    }
}
