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
    @State private var link: String = NMCore.getNezhaDashboardLink()
    @State private var username: String = NMCore.getNezhaDashboardUsername()
    @State private var password: String = NMCore.getNezhaDashboardPassword()
    @State private var isSSLEnabled: Bool = NMCore.getIsNezhaDashboardSSLEnabled()
    
    var body: some View {
        Form {
            Section {
                TextField("Dashboard Link", text: $link)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .onChange(of: link) {
                        link = link.replacingOccurrences(of: "^(http|https)://", with: "", options: .regularExpression)
                    }
            } header: {
                Text("Dashboard Info")
            } footer: {
                Text("Dashboard Link Example: server.hidandelion.com")
            }
            
            Section {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }
            
            Section {
                Toggle("Enable SSL", isOn: $isSSLEnabled)
            }
            
            Section {
                Button("Save & Apply") {
                    NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
                    dashboardViewModel.startMonitoring()
                    dismiss()
                }
            }
        }
        .navigationTitle("Dashboard Settings")
    }
}
