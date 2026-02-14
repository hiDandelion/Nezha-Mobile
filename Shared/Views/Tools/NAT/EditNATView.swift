//
//  EditNATView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct EditNATView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let nat: NATData?

    @State private var isProcessing: Bool = false
    @State private var name: String = ""
    @State private var serverID: Int64 = 0
    @State private var host: String = ""
    @State private var domain: String = ""
    @State private var enabled: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enabled", isOn: $enabled)
                }
                
                Section {
                    TextField("Name", text: $name)
                }

                Section {
                    Picker("Server", selection: $serverID) {
                        Text("Select Server")
                            .tag(Int64(0))
                        ForEach(state.servers) { server in
                            Text(server.name)
                                .tag(server.serverID)
                        }
                    }
                }

                Section {
                    TextField("Host", text: $host)
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
#endif
                    TextField("Domain", text: $domain)
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
#endif
                }
            }
            .formStyle(.grouped)
            .navigationTitle(nat != nil ? "Edit NAT" : "Add NAT")
#if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
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
                    if !isProcessing {
                        if #available(iOS 26, macOS 26, visionOS 26, *) {
                            Button("Done", systemImage: "checkmark", role: .confirm) {
                                execute()
                            }
                        }
                        else {
                            Button("Done") {
                                execute()
                            }
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                if let nat {
                    name = nat.name
                    serverID = nat.serverID
                    host = nat.host
                    domain = nat.domain
                    enabled = nat.isEnabled
                }
            }
        }
    }

    private func execute() {
        isProcessing = true
        if let nat {
            Task {
                do {
                    let _ = try await RequestHandler.updateNAT(nat: nat, name: name, serverID: serverID, host: host, domain: domain, enabled: enabled)
                    await state.refreshNATs()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
        else {
            Task {
                do {
                    let _ = try await RequestHandler.addNAT(name: name, serverID: serverID, host: host, domain: domain, enabled: enabled)
                    await state.refreshNATs()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
    }
}
