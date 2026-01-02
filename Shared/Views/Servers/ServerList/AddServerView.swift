//
//  AddServerView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/2/26.
//

import SwiftUI

struct AddServerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var loadingState: LoadingState = .idle
    @State private var linuxCommand: String = ""
    @State private var macOSCommand: String = ""
    @State private var windowsCommand: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Linux") {
                    Text(linuxCommand)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .monospaced()
                    Button {
                        copy(linuxCommand)
                        
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
                Section("macOS") {
                    Text(macOSCommand)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .monospaced()
                    Button {
                        copy(macOSCommand)
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
                Section("Windows") {
                    Text(windowsCommand)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .monospaced()
                    Button {
                        copy(windowsCommand)
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
            }
            .loadingState(loadingState: loadingState, retryAction: {
                initialize()
            })
            .navigationTitle("Add Server")
            .toolbar {
                if #available(iOS 26, macOS 26, visionOS 26, *) {
                    Button("Done", systemImage: "checkmark", role: .confirm) {
                        dismiss()
                    }
                }
                else {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            initialize()
        }
    }
    
    private func initialize() {
        Task {
            do {
                loadingState = .loading
                let commands = try await RequestHandler.getInstallCommands()
                linuxCommand = commands.0
                macOSCommand = commands.1
                windowsCommand = commands.2
                loadingState = .loaded
            } catch {
                loadingState = .error(error.localizedDescription)
            }
        }
    }
}
