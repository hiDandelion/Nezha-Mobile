//
//  AddDashboardView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var dashboardViewModel: DashboardViewModel
    @State private var dashboardLink: String = NMCore.userDefaults.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = NMCore.userDefaults.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var dashboardSSLEnabled: Bool = NMCore.userDefaults.bool(forKey: "NMDashboardSSLEnabled")
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .onChange(of: dashboardLink) {
                            dashboardLink = dashboardLink.replacingOccurrences(of: "^(http|https)://", with: "", options: .regularExpression)
                        }
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("Dashboard Link Example: server.hidandelion.com")
                }
                
                Section {
                    Toggle("Enable SSL", isOn: $dashboardSSLEnabled)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        NMCore.saveNewDashboardConfigurations(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardSSLEnabled: dashboardSSLEnabled)
                        dashboardViewModel.startMonitoring()
                        dismiss()
                    }
                    .disabled(dashboardLink == "" || dashboardAPIToken == "")
                }
            }
        }
    }
}
