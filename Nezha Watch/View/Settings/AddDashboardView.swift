//
//  AddDashboardView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    var dashboardViewModel: DashboardViewModel
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
                        .textInputAutocapitalization(.never)
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
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Toggle("Enable SSL", isOn: $isSSLEnabled)
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
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        NMCore.saveNewDashboardConfigurations(dashboardLink: link, dashboardUsername: username, dashboardPassword: password, dashboardSSLEnabled: isSSLEnabled)
                        dashboardViewModel.startMonitoring()
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .disabled(link == "" || username == "" || password == "")
                }
            }
        }
    }
}
