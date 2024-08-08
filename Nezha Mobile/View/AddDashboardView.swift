//
//  AddDashboardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("NMDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardAPIToken: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard Info") {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                Section("Help") {
                    Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                    Link("How to get API Token", destination: URL(string: "https://nezha.wiki/guide/api.html")!)
                }
            }
            .navigationTitle("Add Dashboard")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
