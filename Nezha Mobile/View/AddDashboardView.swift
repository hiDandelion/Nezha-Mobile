//
//  AddDashboardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import Zephyr

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("Dashboard Link Example: server.hidandelion.com")
                }
                
                Section("Help") {
                    Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                    Link("How to get API Token", destination: URL(string: "https://nezha.wiki/guide/api.html")!)
                }
            }
            .navigationTitle("Add Dashboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") else {
                            dismiss()
                            return
                        }
                        userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                        userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                        Zephyr.sync()
                        dismiss()
                    }
                    .disabled(dashboardLink == "" || dashboardAPIToken == "")
                }
            }
        }
    }
}
