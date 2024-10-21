//
//  DashboardSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import SwiftUI

struct DashboardSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var dashboardViewModel: DashboardViewModel
    @State private var dashboardLink: String = NMCore.userDefaults.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = NMCore.userDefaults.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var dashboardSSLEnabled: Bool = NMCore.userDefaults.bool(forKey: "NMDashboardSSLEnabled")
    @State private var isShowSuccessfullySavedAlert: Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Dashboard Link", text: $dashboardLink)
                    .autocorrectionDisabled()
                    .onChange(of: dashboardLink) {
                        dashboardLink = dashboardLink.replacingOccurrences(of: "^(http|https)://", with: "", options: .regularExpression)
                    }
                TextField("API Token", text: $dashboardAPIToken)
                    .autocorrectionDisabled()
            } footer: {
                Text("Dashboard Link Example: server.hidandelion.com")
            }
            
            Section {
                Toggle("Enable SSL", isOn: $dashboardSSLEnabled)
            }
            
            Section {
                Button("Save & Apply") {
                    NMCore.saveNewDashboardConfigurations(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardSSLEnabled: dashboardSSLEnabled)
                    dashboardViewModel.startMonitoring()
                    isShowSuccessfullySavedAlert.toggle()
                }
                .alert("Successfully Saved", isPresented: $isShowSuccessfullySavedAlert) {
                    Button("OK", role: .cancel) {
                        isShowSuccessfullySavedAlert = false
                    }
                }
            }
        }
        .padding()
        .tabItem {
            Label("General", systemImage: "gearshape")
        }
    }
}
