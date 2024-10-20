//
//  PrepareConnectionView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData
import Cache

struct PrepareConnectionView: View {
    @Query var identities: [Identity]
    let host: String?
    @State private var mannualHost: String = ""
    @State private var port: String = "22"
    @State private var identity: Identity?
    @State private var isShowAddIdentitySheet: Bool = false
    let storage = try? Storage<String, Int>(
        diskConfig: DiskConfig(name: "NMHostSSHPort"),
        memoryConfig: MemoryConfig(expiry: .never),
        fileManager: FileManager(),
        transformer: TransformerFactory.forCodable(ofType: Int.self)
    )
    
    var body: some View {
        NavigationStack {
            Form {
                if host == nil {
                    Section("Host") {
                        TextField("Host", text: $mannualHost)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    }
                }
                
                Section("Port") {
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                Section("Authentication") {
                    Picker("Identity", selection: $identity) {
                        Text("Select")
                            .tag(nil as Identity?)
                        
                        ForEach(identities) { identity in
                            Text("\(identity.name! != "" ? identity.name! : String(localized: "Untitled")) (\(identity.username!))")
                                .tag(identity as Identity?)
                        }
                    }
                    
                    Button {
                        isShowAddIdentitySheet = true
                    } label: {
                        Label("New Identity", systemImage: "plus")
                    }
                    .sheet(isPresented: $isShowAddIdentitySheet) {
                        AddIdentityView(isShowAddIdentitySheet: $isShowAddIdentitySheet)
                    }
                }
            }
            .navigationTitle("Connection")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if let port = Int(port),
                       let identity,
                       let username = identity.username,
                       host != nil || (host == nil && mannualHost != "") {
                        NavigationLink("Start", destination: TerminalView(host: host ?? mannualHost, port: port, username: username, password: identity.password, privateKey: identity.privateKeyString, privateKeyType: identity.privateKeyType))
                    }
                    else {
                        NavigationLink("Start", destination: EmptyView())
                            .disabled(true)
                    }
                }
            }
            .onAppear {
                // Retrieve corresponding port for the host from cache
                if let host, let cachedPort = try? storage?.object(forKey: host) {
                    port = String(cachedPort)
                }
            }
        }
    }
}
