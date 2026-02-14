//
//  EditDDNSView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct EditDDNSView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let ddns: DDNSData?

    @State private var isProcessing: Bool = false
    @State private var providers: [String] = []
    @State private var name: String = ""
    @State private var provider: String = ""
    @State private var domainsText: String = ""
    @State private var accessID: String = ""
    @State private var accessSecret: String = ""
    @State private var enableIPv4: Bool = true
    @State private var enableIPv6: Bool = false
    @State private var maxRetries: Int64 = 3
    @State private var webhookURL: String = ""
    @State private var webhookMethod: Int64 = 1
    @State private var webhookRequestType: Int64 = 1
    @State private var webhookRequestBody: String = ""
    @State private var webhookHeaders: String = ""

    var isWebhookProvider: Bool {
        provider.lowercased() == "webhook"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }

                Section {
                    Picker("Provider", selection: $provider) {
                        Text("Select Provider")
                            .tag("")
                        ForEach(providers, id: \.self) { p in
                            Text(p)
                                .tag(p)
                        }
                    }
                }

                Section {
                    TextEditor(text: $domainsText)
                        .monospaced()
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
#endif
                        .frame(minHeight: 60)
                } header: {
                    Text("Domains")
                } footer: {
                    Text("One domain per line")
                }

                if !isWebhookProvider {
                    Section("Credentials") {
                        TextField("Access ID", text: $accessID)
                            .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
#endif
                        SecureField("Access Secret", text: $accessSecret)
                    }
                }

                Section("IP Settings") {
                    Toggle("Enable IPv4", isOn: $enableIPv4)
                    Toggle("Enable IPv6", isOn: $enableIPv6)
                }
                
                Section("Max Retries") {
                    TextField("Max Retry Count", value: $maxRetries, format: .number)
#if os(iOS) || os(visionOS)
                        .keyboardType(.numberPad)
#endif
                }

                if isWebhookProvider {
                    Section("Webhook") {
                        TextField("Webhook URL", text: $webhookURL)
                            .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
#endif
                        TextEditor(text: $webhookRequestBody)
                            .monospaced()
                            .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
#endif
                            .frame(minHeight: 60)
                        TextField("Webhook Headers", text: $webhookHeaders)
                            .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
#endif
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(ddns != nil ? "Edit DDNS" : "Add DDNS")
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
                if let ddns {
                    name = ddns.name
                    provider = ddns.provider
                    domainsText = ddns.domains.joined(separator: "\n")
                    accessID = ddns.accessID
                    accessSecret = ddns.accessSecret
                    enableIPv4 = ddns.enableIPv4
                    enableIPv6 = ddns.enableIPv6
                    maxRetries = ddns.maxRetries
                    webhookURL = ddns.webhookURL
                    webhookMethod = ddns.webhookMethod
                    webhookRequestType = ddns.webhookRequestType
                    webhookRequestBody = ddns.webhookRequestBody
                    webhookHeaders = ddns.webhookHeaders
                }
                loadProviders()
            }
        }
    }

    private func loadProviders() {
        Task {
            do {
                let response = try await RequestHandler.getDDNSProviders()
                providers = response.data ?? []
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func execute() {
        isProcessing = true
        let domains = domainsText.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
        if let ddns {
            Task {
                do {
                    let _ = try await RequestHandler.updateDDNS(ddns: ddns, name: name, provider: provider, domains: domains, accessID: accessID, accessSecret: accessSecret, enableIPv4: enableIPv4, enableIPv6: enableIPv6, maxRetries: maxRetries, webhookURL: webhookURL, webhookMethod: webhookMethod, webhookRequestType: webhookRequestType, webhookRequestBody: webhookRequestBody, webhookHeaders: webhookHeaders)
                    await state.refreshDDNS()
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
                    let _ = try await RequestHandler.addDDNS(name: name, provider: provider, domains: domains, accessID: accessID, accessSecret: accessSecret, enableIPv4: enableIPv4, enableIPv6: enableIPv6, maxRetries: maxRetries, webhookURL: webhookURL, webhookMethod: webhookMethod, webhookRequestType: webhookRequestType, webhookRequestBody: webhookRequestBody, webhookHeaders: webhookHeaders)
                    await state.refreshDDNS()
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
