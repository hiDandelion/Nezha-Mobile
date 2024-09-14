//
//  AlertDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI

struct AlertDetailView: View {
    @EnvironmentObject var notificationState: NotificationState
    let time: Date?
    let title: String?
    let content: String?
    
    var body: some View {
        Form {
            if let time = time {
                Section("Time") {
                    Text(time.formatted(date: .long, time: .standard))
                        .foregroundStyle(.secondary)
                }
            }
            
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
