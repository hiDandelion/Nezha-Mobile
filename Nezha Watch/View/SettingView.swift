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
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: dashboardLink) {
                            dashboardViewModel.stopMonitoring()
                        }
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: dashboardAPIToken) {
                            dashboardViewModel.stopMonitoring()
                        }
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("SSL must be enabled. Dashboard Link Example: server.hidandelion.com")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if !dashboardViewModel.isMonitoringEnabled {
                            dashboardViewModel.startMonitoring()
                        }
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") else {
                            dismiss()
                            return
                        }
                        if !dashboardViewModel.isMonitoringEnabled {
                            userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                            userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                            userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                            NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
                            NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                            NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                            dashboardViewModel.startMonitoring()
                        }
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
            }
        }
    }
}
