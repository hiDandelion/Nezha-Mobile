//
//  ServerConfigView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct ServerConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let serverID: Int64

    @State private var isLoading: Bool = true
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    @State private var debug: Bool = false
    @State private var disableAutoUpdate: Bool = false
    @State private var disableCommandExecute: Bool = false
    @State private var disableForceUpdate: Bool = false
    @State private var disableNAT: Bool = false
    @State private var disableSendQuery: Bool = false
    @State private var gpu: Bool = false
    @State private var temperature: Bool = false
    @State private var skipConnectionCount: Bool = false
    @State private var skipProcsCount: Bool = false
    @State private var hardDrivePartitionAllowlist: String = ""
    @State private var nicAllowlist: String = ""
    @State private var ipReportPeriod: Int64 = 0
    @State private var reportDelay: Int64 = 0

    var serverName: String {
        state.servers.first(where: { $0.serverID == serverID })?.name ?? "#\(serverID)"
    }

    var body: some View {
        Form {
            Section("Flags") {
                Toggle("Debug", isOn: $debug)
                Toggle("GPU Monitoring", isOn: $gpu)
                Toggle("Temperature Monitoring", isOn: $temperature)
            }

            Section("Disable Features") {
                Toggle("Disable Auto Update", isOn: $disableAutoUpdate)
                Toggle("Disable Force Update", isOn: $disableForceUpdate)
                Toggle("Disable Command Execute", isOn: $disableCommandExecute)
                Toggle("Disable NAT", isOn: $disableNAT)
                Toggle("Disable Send Query", isOn: $disableSendQuery)
            }

            Section("Skip") {
                Toggle("Skip Connection Count", isOn: $skipConnectionCount)
                Toggle("Skip Process Count", isOn: $skipProcsCount)
            }

            Section("Hard Drive Partition Allowlist") {
                TextField("Partitions (Comma separated)", text: $hardDrivePartitionAllowlist)
                    .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                    .autocapitalization(.none)
#endif
            }
            
            Section("NIC Allowlist") {
                TextField("NICs (Comma separated)", text: $nicAllowlist)
                    .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                    .autocapitalization(.none)
#endif
            }
            
            Section("IP Report Period") {
                TextField("Seconds", value: $ipReportPeriod, format: .number)
#if os(iOS) || os(visionOS)
                    .keyboardType(.numberPad)
#endif
            }

            Section("Report Delay") {
                TextField("Seconds", value: $reportDelay, format: .number)
#if os(iOS) || os(visionOS)
                    .keyboardType(.numberPad)
#endif
            }

        }
        .formStyle(.grouped)
        .navigationTitle(serverName)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if !isSaving {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Save", systemImage: "checkmark", role: .confirm) {
                            saveConfig()
                        }
                    }
                    else {
                        Button("Save") {
                            saveConfig()
                        }
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            }
            if let errorMessage {
                VStack(spacing: 20) {
                    Text("An error occurred")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                    Button("Retry") {
                        loadConfig()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadConfig()
        }
    }

    private func loadConfig() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response = try await RequestHandler.getServerConfig(serverID: serverID)
                if let configString = response.data, let configData = configString.data(using: .utf8) {
                    let config = try JSONDecoder().decode(AgentConfig.self, from: configData)
                    debug = config.debug ?? false
                    disableAutoUpdate = config.disable_auto_update ?? false
                    disableCommandExecute = config.disable_command_execute ?? false
                    disableForceUpdate = config.disable_force_update ?? false
                    disableNAT = config.disable_nat ?? false
                    disableSendQuery = config.disable_send_query ?? false
                    gpu = config.gpu ?? false
                    temperature = config.temperature ?? false
                    skipConnectionCount = config.skip_connection_count ?? false
                    skipProcsCount = config.skip_procs_count ?? false
                    hardDrivePartitionAllowlist = config.hard_drive_partition_allowlist?.joined(separator: ",") ?? ""
                    nicAllowlist = config.nic_allowlist?.joined(separator: ",") ?? ""
                    ipReportPeriod = config.ip_report_period ?? 0
                    reportDelay = config.report_delay ?? 0
                }
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func saveConfig() {
        isSaving = true
        let config = AgentConfig(
            debug: debug,
            disable_auto_update: disableAutoUpdate,
            disable_command_execute: disableCommandExecute,
            disable_force_update: disableForceUpdate,
            disable_nat: disableNAT,
            disable_send_query: disableSendQuery,
            gpu: gpu,
            temperature: temperature,
            skip_connection_count: skipConnectionCount,
            skip_procs_count: skipProcsCount,
            hard_drive_partition_allowlist: hardDrivePartitionAllowlist.isEmpty ? nil : hardDrivePartitionAllowlist.split(separator: ",").map(String.init),
            nic_allowlist: nicAllowlist.isEmpty ? nil : nicAllowlist.split(separator: ",").map(String.init),
            ip_report_period: ipReportPeriod,
            report_delay: reportDelay
        )
        Task {
            do {
                let configData = try JSONEncoder().encode(config)
                let configString = String(data: configData, encoding: .utf8) ?? "{}"
                let _ = try await RequestHandler.setServerConfig(config: configString, servers: [serverID])
                isSaving = false
                dismiss()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
                isSaving = false
            }
        }
    }
}
