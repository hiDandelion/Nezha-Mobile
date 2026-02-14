//
//  NATDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct NATDetailView: View {
    @Environment(NMState.self) private var state
    let natID: Int64
    var nat: NATData? {
        state.nats.first(where: { $0.natID == natID })
    }

    @State private var isShowEditNATSheet: Bool = false

    var body: some View {
        if let nat {
            let serverName = state.servers.first(where: { $0.serverID == nat.serverID })?.name ?? String(nat.serverID)
            Form {
                NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(nat.name)"))
                NMUI.PieceOfInfo(systemImage: "server.rack", name: "Server", content: Text("\(serverName)"))
                NMUI.PieceOfInfo(systemImage: "network", name: "Host", content: Text("\(nat.host)"))
                NMUI.PieceOfInfo(systemImage: "globe", name: "Domain", content: Text("\(nat.domain)"))
                NMUI.PieceOfInfo(systemImage: nat.isEnabled ? "checkmark.circle" : "xmark.circle", name: "Enabled", content: Text(nat.isEnabled ? "Yes" : "No"))
            }
            .formStyle(.grouped)
            .navigationTitle(nameCanBeUntitled(nat.name))
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowEditNATSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowEditNATSheet, content: {
                EditNATView(nat: nat)
            })
        }
    }
}
