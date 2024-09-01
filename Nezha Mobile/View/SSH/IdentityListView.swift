//
//  IdentityListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/31/24.
//

import SwiftUI
import SwiftData

enum IdentityAuthenticationMethod: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case password = "Password"
    case privateKey = "Private Key"
}

struct IdentityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var identities: [Identity]
    @State private var isShowAddIdentitySheet: Bool = false
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var authenticationMethod: IdentityAuthenticationMethod = .password
    @State private var password: String = ""
    @State private var privateKeyType: PrivateKeyType = .ed25519
    @State private var privateKeyString: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(identities) { identity in
                    Text(identity.name! != "" ? identity.name! : String(localized: "Untitled"))
                }
                .onDelete { offsets in
                    withAnimation {
                        for index in offsets {
                            modelContext.delete(identities[index])
                        }
                    }
                }
            }
            .navigationTitle("Identities")
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowAddIdentitySheet = true
                    } label: {
                        Label("Add", systemImage: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowAddIdentitySheet) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $name)
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
    }
}
