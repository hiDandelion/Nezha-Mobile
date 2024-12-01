//
//  DashboardSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/19/24.
//

import SwiftUI

struct DashboardSettingsView: View {
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @State private var link: String = NMCore.getNezhaDashboardLink()
    @State private var username: String = NMCore.getNezhaDashboardUsername()
    @State private var password: String = NMCore.getNezhaDashboardPassword()
    @State private var isSSLEnabled: Bool = NMCore.getIsNezhaDashboardSSLEnabled()
    @State private var isShowSuccessfullySavedAlert: Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Dashboard Link", text: $link)
                    .autocorrectionDisabled()
                    .onChange(of: link) {
                        link = link.replacingOccurrences(of: "^(http|https)://", with: "", options: .regularExpression)
                    }
            } footer: {
                Text("Dashboard Link Example: server.hidandelion.com")
            }
            
            Section {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
            }
            
            Section {
                Toggle("Enable SSL", isOn: $isSSLEnabled)
            }
            
            Section {
                Button("Save & Apply") {
                    NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
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
