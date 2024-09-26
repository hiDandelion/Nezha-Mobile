//
//  AgentSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
//

import SwiftUI

struct AgentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("NMDashboardGRPCLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardGRPCLink: String = ""
    @AppStorage("NMDashboardGRPCPort", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardGRPCPort: String = "5555"
    @AppStorage("NMAgentSecret", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var agentSecret: String = ""
    
    var body: some View {
        Form {
            Section("Dashboard GRPC Info") {
                TextField("Dashboard GRPC Link", text: $dashboardGRPCLink)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                TextField("Dashboard GRPC Port", text: $dashboardGRPCPort)
                    .keyboardType(.numberPad)
            }
            
            Section("Agent Parameters") {
                TextField("Secret", text: $agentSecret)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            }
        }
        .navigationTitle("Agent Settings")
    }
}
