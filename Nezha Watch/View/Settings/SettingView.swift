//
//  SettingView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    NavigationLink("Dashboard Settings") {
                        DashboardSettingsView(dashboardViewModel: dashboardViewModel)
                    }
                }
                
                Section("Notifications") {
                    let pushNotificationsToken = NMCore.userDefaults.string(forKey: "NMWatchPushNotificationsToken")!
                    if pushNotificationsToken != "" {
                        ShareLink(item: pushNotificationsToken) {
                            Text("Share Token")
                        }
                    }
                    else {
                        Text("Push Notifications Not Available")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
            }
        }
    }
}
