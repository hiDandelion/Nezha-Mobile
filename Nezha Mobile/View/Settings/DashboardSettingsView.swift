//
//  DashboardSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/3/24.
//

import SwiftUI

struct DashboardSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    
    var body: some View {
        Form {
            Section {
                TextField("Dashboard Link", text: $dashboardLink)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                TextField("API Token", text: $dashboardAPIToken)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                Button("Save & Reconnect") {
                    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
                    userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                    userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                    userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
                    NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                    NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    dashboardViewModel.startMonitoring()
                    dismiss()
                }
            } header: {
                Text("Dashboard Info")
            } footer: {
                Text("SSL must be enabled. Dashboard Link Example: server.hidandelion.com")
            }
        }
        .navigationTitle("Dashboard Settings")
    }
}
