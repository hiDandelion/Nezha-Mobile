//
//  ServerConfigPickerView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct ServerConfigPickerView: View {
    @Environment(NMState.self) private var state

    var body: some View {
        List {
            if !state.servers.isEmpty {
                ForEach(state.servers) { server in
                    NavigationLink(value: server.serverID) {
                        Text(server.name)
                    }
                }
            }
            else {
                Text("No Server")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.dashboardLoadingState) {
            state.loadDashboard()
        }
        .navigationTitle("Server Config")
    }
}
