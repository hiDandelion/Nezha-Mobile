//
//  AddDashboardView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @Binding var isShowingOnboarding: Bool
    @State private var link: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isSSLEnabled: Bool = true
    
    var body: some View {
        NavigationStack {
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
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Link("User Guide", destination: NMCore.userGuideURL)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
                        dashboardViewModel.startMonitoring()
                        isShowingOnboarding = false
                        dismiss()
                    }
                    .disabled(link == "" || username == "" || password == "")
                }
            }
        }
    }
}
