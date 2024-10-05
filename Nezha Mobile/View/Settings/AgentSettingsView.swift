//
//  AgentSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
//

import SwiftUI

struct AgentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dashboardGRPCLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardGRPCLink") ?? ""
    @State private var dashboardGRPCPort: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardGRPCPort") ?? "5555"
    @State private var agentSecret: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMAgentSecret") ?? "5555"
    @State private var isShowPrivacyNotice: Bool = false
    
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
            
            Section {
                Button("Save & Apply") {
                    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
                    userDefaults.set(dashboardGRPCLink, forKey: "NMDashboardGRPCLink")
                    userDefaults.set(dashboardGRPCPort, forKey: "NMDashboardGRPCPort")
                    userDefaults.set(agentSecret, forKey: "NMAgentSecret")
                    userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    NSUbiquitousKeyValueStore().set(dashboardGRPCLink, forKey: "NMDashboardGRPCLink")
                    NSUbiquitousKeyValueStore().set(dashboardGRPCPort, forKey: "NMDashboardGRPCPort")
                    NSUbiquitousKeyValueStore().set(agentSecret, forKey: "NMAgentSecret")
                    NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    dismiss()
                }
            }
        }
        .navigationTitle("Agent Settings")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    isShowPrivacyNotice = true
                } label: {
                    Label("Privacy Notice", systemImage: "hand.raised.fill")
                }
            }
        }
        .sheet(isPresented: $isShowPrivacyNotice) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("By using Nezha Mobile as an agent, you acknowledge the following matrix of your device will be obtained:")
                        Text("- OS Version\n- Model Identifier\n- CPU Usage\n- Memory Usage\n- Disk Usage\n- Data Usage\n- Boot Time\n- Uptime")
                        Text("These data will be sent to the Dashboard server you configured in Agent Settings. We will not save or share any of your data.")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .navigationTitle("Privacy Notice")
                .padding()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isShowPrivacyNotice = false
                        }
                    }
                }
            }
        }
    }
}
