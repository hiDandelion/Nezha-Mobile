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
    @State private var isShowRenameIdentityAlert: Bool = false
    @State private var identityToRename: Identity?
    @State private var newNameForIdentity: String = ""
    
    var body: some View {
        NavigationStack {
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
                            modelContext.delete(identity)
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
                            modelContext.delete(identity)
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
                        identityToRename?.name = newNameForIdentity
                        isShowRenameIdentityAlert = false
                    }
                    Button("Cancel", role: .cancel) {
                        isShowRenameIdentityAlert = false
                    }
                }
            )
        }
    }
}
