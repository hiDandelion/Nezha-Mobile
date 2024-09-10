//
//  AlertListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/9/24.
//

import SwiftUI

struct AlertListView: View {
    @EnvironmentObject var notificationState: NotificationState
    @State private var serverAlerts: [ServerAlert] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if !serverAlerts.isEmpty {
                    List {
                        
                    }
                }
                else {
                    ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
                }
            }
            .navigationDestination(isPresented: $notificationState.shouldNavigateToNotificationView) {
                NotificationDetailView()
            }
        }
        .onAppear {
            serverAlerts = []
        }
    }
}
