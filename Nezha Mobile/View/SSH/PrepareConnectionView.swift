//
//  PrepareConnectionView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import SwiftData

struct PrepareConnectionView: View {
    @Query var identities: [Identity]
    let host: String?
    @State var port: String = "22"
    @State var identity: Identity?
    @State private var isShowAddIdentitySheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Port") {
                    TextField("Port", text: $port)
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
                    
                    Button("Add Identity") {
                        isShowAddIdentitySheet = true
                    }
                    .sheet(isPresented: $isShowAddIdentitySheet) {
                        AddIdentityView(isShowAddIdentitySheet: $isShowAddIdentitySheet)
                    }
                }
                
                if let host {
                    Section("Connection") {
                        if let identity, let password = identity.password {
                            NavigationLink("Start", destination: TerminalView(host: host, port: Int(port) ?? 22, username: identity.username!, password: password, privateKey: nil, privateKeyType: nil))
                        }
                        else if let identity, let privateKey = identity.privateKeyString, let privateKeyType = identity.privateKeyType {
                            NavigationLink("Start", destination: TerminalView(host: host, port: Int(port) ?? 22, username: identity.username!, password: nil, privateKey: privateKey, privateKeyType: privateKeyType))
                        }
                        else {
                            NavigationLink("Start", destination: EmptyView())
                                .disabled(true)
                        }
                    }
                }
            }
            .navigationTitle("Connection")
        }
    }
}
