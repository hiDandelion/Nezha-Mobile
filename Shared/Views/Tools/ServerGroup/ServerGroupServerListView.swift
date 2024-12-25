//
//  ServerGroupServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/3/24.
//

import SwiftUI

struct ServerGroupServerListView: View {
    @Environment(\.editMode) private var editMode
    @Environment(NMState.self) private var state
    let serverGroup: ServerGroup
    var serverInGroup: [ServerData] {
        state.servers.filter {
            serverGroup.serverIDs.contains($0.serverID)
        }
    }
    @Binding var selectedServerIDs: Set<Int64>
    
    var body: some View {
        if (!serverGroup.serverIDs.isEmpty && editMode?.wrappedValue == .inactive) || (!state.servers.isEmpty && editMode?.wrappedValue == .active) {
            List(selection: $selectedServerIDs) {
                if editMode?.wrappedValue == .inactive {
                    ForEach(serverInGroup) { server in
                        ServerTitle(server: server, lastUpdateTime: nil)
                            .tag(server.serverID)
                    }
                }
                if editMode?.wrappedValue == .active {
                    ForEach(state.servers) { server in
                        ServerTitle(server: server, lastUpdateTime: nil)
                            .tag(server.serverID)
                    }
                }
            }
        }
        else {
            ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
        }
    }
}
