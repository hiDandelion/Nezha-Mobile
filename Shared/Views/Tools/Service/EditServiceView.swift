//
//  EditServiceView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/10/24.
//

import SwiftUI

struct EditServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let service: ServiceData?
    
    @State private var isProcessing: Bool = false
    @State private var name: String = ""
    @State private var type: ServiceType = .get
    @State private var target: String = ""
    @State private var interval: Int64 = 30
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(ServiceType.allCases) { type in
                            Text(type.title)
                                .tag(type)
                        }
                    }
                    TextField("Target", text: $target)
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
#endif
                }
                
                Section("Interval") {
                    TextField("Seconds", value: $interval, format: .number)
#if os(iOS) || os(visionOS)
                        .keyboardType(.numberPad)
#endif
                }
            }
            .formStyle(.grouped)
            .navigationTitle(service != nil ? "Edit Service" : "Add Service")
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
                if let service {
                    name = service.name
                    type = service.type
                    target = service.target
                    interval = service.interval
                }
            }
        }
    }
    
    private func execute() {
        isProcessing = true
        if let service {
            Task {
                do {
                    let _ = try await RequestHandler.updateService(service: service, name: name, type: type, target: target, interval: Int64(interval))
                    await state.refreshServices()
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
                    let _ = try await RequestHandler.addService(name: name, type: type, target: target, interval: interval)
                    await state.refreshServices()
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
