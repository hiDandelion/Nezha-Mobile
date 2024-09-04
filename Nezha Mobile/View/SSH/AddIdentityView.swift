//
//  AddIdentityView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import SwiftData

struct AddIdentityView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isShowAddIdentitySheet: Bool
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var authenticationMethod: IdentityAuthenticationMethod = .password
    @State private var password: String = ""
    @State private var privateKeyType: PrivateKeyType = .ed25519
    @State private var privateKeyString: String = ""
    @State private var isImportingFromFile: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }
                
                Section("Credentials") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                    Picker("Authentication Method", selection: $authenticationMethod) {
                        ForEach(IdentityAuthenticationMethod.allCases) { authenticationMethod in
                            Text(authenticationMethod.rawValue)
                                .tag(authenticationMethod)
                        }
                    }
                    switch(authenticationMethod) {
                    case .password:
                        TextField("Password", text: $password)
                    case .privateKey:
                        Picker("Private Key Type", selection: $privateKeyType) {
                            ForEach(PrivateKeyType.allCases) { privateKeyType in
                                Text(privateKeyType.rawValue)
                                    .tag(privateKeyType)
                            }
                        }
                        TextEditor(text: $privateKeyString)
                            .frame(minHeight: 100)
                        Button("Import From File") {
                            isImportingFromFile = true
                        }
                        .fileImporter(
                            isPresented: $isImportingFromFile,
                            allowedContentTypes: [.item],
                            allowsMultipleSelection: false
                        ) { result in
                            do {
                                guard let selectedFile: URL = try result.get().first else { return }
                                if selectedFile.startAccessingSecurityScopedResource() {
                                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                                    
                                    if let content = try? String(contentsOf: selectedFile) {
                                        privateKeyString = content
                                    } else {
                                        let attributes = try FileManager.default.attributesOfItem(atPath: selectedFile.path)
                                        let fileSize = attributes[.size] as? Int64 ?? 0
                                        _ = debugLog("File Importer Error: Non readable file \(selectedFile.lastPathComponent) (\(fileSize) bytes)")
                                    }
                                } else {
                                    _ = debugLog("File Importer Error: File access declined")
                                }
                            } catch {
                                _ = debugLog("File Importer Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Identity")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        switch(authenticationMethod) {
                        case .password:
                            let newIdentity = Identity(name: name, username: username, password: password)
                            modelContext.insert(newIdentity)
                        case .privateKey:
                            let newIdentity = Identity(name: name, username: username, privateKeyString: privateKeyString, privateKeyType: privateKeyType)
                            modelContext.insert(newIdentity)
                        }
                        isShowAddIdentitySheet = false
                    }
                    .disabled(name == "" || username == "" || (authenticationMethod == .password && password == "") || (authenticationMethod == .privateKey && privateKeyString == ""))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowAddIdentitySheet = false
                    }
                }
            }
        }
    }
}
