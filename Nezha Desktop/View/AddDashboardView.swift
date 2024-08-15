//
//  AddDashboardView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("SSL must be enabled. Dashboard Link Example: server.hidandelion.com")
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
                        userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                        userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                        NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
                        NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                        dashboardViewModel.startMonitoring()
                        dismiss()
                    }
                    .disabled(dashboardLink == "" || dashboardAPIToken == "")
                }
            }
        }
    }
}
