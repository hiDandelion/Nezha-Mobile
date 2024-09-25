//
//  PrepareConnectionView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct PrepareConnectionView: View {
    @Query var identities: [Identity]
    let host: String?
    @State private var mannualHost: String = ""
    @State private var port: String = "22"
    @State private var identity: Identity?
    @State private var isShowAddIdentitySheet: Bool = false
    
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
                        Text("Select Identity")
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
                    if let host, let port = Int(port), let identity, let password = identity.password {
                        NavigationLink("Start", destination: TerminalView(host: host, port: port, username: identity.username!, password: password, privateKey: nil, privateKeyType: nil))
                    }
                    else if let host, let port = Int(port), let identity, let privateKey = identity.privateKeyString, let privateKeyType = identity.privateKeyType {
                        NavigationLink("Start", destination: TerminalView(host: host, port: port, username: identity.username!, password: nil, privateKey: privateKey, privateKeyType: privateKeyType))
                    }
                    else if host == nil, mannualHost != "", let port = Int(port), let identity, let password = identity.password {
                        NavigationLink("Start", destination: TerminalView(host: mannualHost, port: port, username: identity.username!, password: password, privateKey: nil, privateKeyType: nil))
                    }
                    else if host == nil, mannualHost != "", let port = Int(port), let identity, let privateKey = identity.privateKeyString, let privateKeyType = identity.privateKeyType {
                        NavigationLink("Start", destination: TerminalView(host: mannualHost, port: port, username: identity.username!, password: nil, privateKey: privateKey, privateKeyType: privateKeyType))
                    }
                    else {
                        NavigationLink("Start", destination: EmptyView())
                            .disabled(true)
                    }
                }
            }
        }
    }
}
