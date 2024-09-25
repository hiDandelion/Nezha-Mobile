//
//  IdentityListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/31/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

enum IdentityAuthenticationMethod: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case password = "Password"
    case privateKey = "Private Key"
}

struct IdentityListView: View {
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \Identity.timestamp, order: .reverse) var identities: [Identity]
    @State private var isShowAddIdentitySheet: Bool = false
    @State private var isShowRenameIdentityAlert: Bool = false
    @State private var identityToRename: Identity?
    @State private var newNameForIdentity: String = ""
    
    var body: some View {
        List {
            ForEach(identities) { identity in
                HStack {
                    if let privateKeyType = identity.privateKeyType {
                        IdentityRowView(name: identity.name!, username: identity.username!, identityAuthenticationMethod: .privateKey, privateKeyType: privateKeyType)
                    }
                    else {
                        IdentityRowView(name: identity.name!, username: identity.username!, identityAuthenticationMethod: .password, privateKeyType: nil)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        let createDataHandler = createDataHandler
                        Task {
                            if let dataHandler = await createDataHandler() {
                                _ = try await dataHandler.deleteIdentity(id: identity.persistentModelID)
                            }
                        }
                    } label: {
                        Text("Delete")
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        identityToRename = identity
                        isShowRenameIdentityAlert = true
                    } label: {
                        Text("Rename")
                    }
                }
                .contextMenu(ContextMenu(menuItems: {
                    Button {
                        identityToRename = identity
                        isShowRenameIdentityAlert = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        let createDataHandler = createDataHandler
                        Task {
                            if let dataHandler = await createDataHandler() {
                                _ = try await dataHandler.deleteIdentity(id: identity.persistentModelID)
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }))
            }
        }
        .navigationTitle("Identities")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddIdentitySheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddIdentitySheet) {
            AddIdentityView(isShowAddIdentitySheet: $isShowAddIdentitySheet)
        }
        .alert(
            Text("Rename Identity"),
            isPresented: $isShowRenameIdentityAlert,
            actions: {
                TextField("New Name", text: $newNameForIdentity)
                Button("OK") {
                    if let identityToRename {
                        let createDataHandler = createDataHandler
                        Task {
                            if let dataHandler = await createDataHandler() {
                                _ = try await dataHandler.renameIdentity(id: identityToRename.persistentModelID, name: newNameForIdentity)
                            }
                        }
                    }
                    isShowRenameIdentityAlert = false
                }
                Button("Cancel", role: .cancel) {
                    isShowRenameIdentityAlert = false
                }
            }
        )
    }
}
