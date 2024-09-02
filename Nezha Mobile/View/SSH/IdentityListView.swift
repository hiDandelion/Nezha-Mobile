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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(identities) { identity in
                    if let privateKeyType = identity.privateKeyType {
                        IdentityRowView(name: identity.name!, username: identity.username!, identityAuthenticationMethod: .privateKey, privateKeyType: privateKeyType)
                    }
                    else {
                        IdentityRowView(name: identity.name!, username: identity.username!, identityAuthenticationMethod: .password, privateKeyType: nil)
                    }
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
                AddIdentityView(isShowAddIdentitySheet: $isShowAddIdentitySheet)
            }
        }
    }
}
