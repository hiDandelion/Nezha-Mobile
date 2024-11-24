//
//  DashboardSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct DashboardSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var dashboardViewModel: DashboardViewModel
    @State private var dashboardLink: String = NMCore.userDefaults.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = NMCore.userDefaults.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var dashboardSSLEnabled: Bool = NMCore.userDefaults.bool(forKey: "NMDashboardSSLEnabled")
    
    var body: some View {
        Form {
            Section {
                TextField("Dashboard Link", text: $dashboardLink)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .onChange(of: dashboardLink) {
                        dashboardLink = dashboardLink.replacingOccurrences(of: "^(http|https)://", with: "", options: .regularExpression)
                    }
                TextField("API Token", text: $dashboardAPIToken)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            } header: {
                Text("Dashboard Info")
            } footer: {
                VStack(alignment: .leading) {
                    Text("Dashboard Link Example: server.hidandelion.com")
                    Text("Latest Supported Nezha Version: 0.20.5")
                }
            }
            
            Section {
                Toggle("Enable SSL", isOn: $dashboardSSLEnabled)
            }
            
            Section {
                Button("Save & Apply") {
                    NMCore.saveNewDashboardConfigurations(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardSSLEnabled: dashboardSSLEnabled)
                    dashboardViewModel.startMonitoring()
                    dismiss()
                }
            }
        }
        .navigationTitle("Dashboard Settings")
    }
}
