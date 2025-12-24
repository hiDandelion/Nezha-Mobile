//
//  AddDashboardView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
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
                    if #available(macOS 26, *) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) {
                            dismiss()
                        }
                    }
                    else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if #available(macOS 26, *) {
                        Button("Done", systemImage: "checkmark", role: .confirm) {
                            NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
                            state.loadDashboard()
                            isShowingOnboarding = false
                            dismiss()
                        }
                        .disabled(link == "" || username == "" || password == "")
                    }
                    else {
                        Button("Done") {
                            NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
                            state.loadDashboard()
                            isShowingOnboarding = false
                            dismiss()
                        }
                        .disabled(link == "" || username == "" || password == "")
                    }
                }
            }
        }
    }
}
