//
//  ProfileView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var isLoading: Bool = true
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    @State private var username: String = ""
    @State private var agentSecret: String = ""
    @State private var newPassword: String = ""

    var body: some View {
        Form {
            Section("Agent Secet") {
                Text(agentSecret)
                    .copiable(agentSecret)
                    .monospaced()
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
            }

            Section("Username") {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                    .autocapitalization(.none)
#endif
            }

            Section {
                SecureField("New Password", text: $newPassword)
            } header: {
                Text("Password")
            } footer: {
                Text("Leave empty to keep current password")
            }

        }
        .formStyle(.grouped)
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if !isSaving {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Save", systemImage: "checkmark", role: .confirm) {
                            saveProfile()
                        }
                    }
                    else {
                        Button("Save") {
                            saveProfile()
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
                        loadProfile()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadProfile()
        }
    }

    private func loadProfile() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response = try await RequestHandler.getProfile()
                if let data = response.data {
                    agentSecret = data.agent_secret
                    username = data.username ?? ""
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

    private func saveProfile() {
        isSaving = true
        Task {
            do {
                let _ = try await RequestHandler.updateProfile(username: username, newPassword: newPassword)
                newPassword = ""
                isSaving = false
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
                isSaving = false
            }
        }
    }
}
