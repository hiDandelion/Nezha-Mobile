//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/23/24.
//

import SwiftUI

enum ServerDetailTab: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case status = "Status"
    case monitors = "Monitors"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ServerDetailView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(NMState.self) private var state
    var id: String
    @State private var activeTab: ServerDetailTab = .status
    
    var body: some View {
        NavigationStack {
            if let server = state.servers.first(where: { $0.id == id }) {
                VStack {
                    if server.status.uptime != 0 {
                        VStack {
                            picker
                            Spacer()
                            switch(activeTab) {
                            case .status:
                                ServerDetailStatusView(server: server)
                                    .tag(ServerDetailTab.status)
                            case .monitors:
                                ServerDetailPingView(server: server)
                                    .tag(ServerDetailTab.monitors)
                            }
                            Spacer()
                        }
                    }
                    else {
                        serverUnavailable(server: server)
                    }
                }
                .navigationTitle(server.name)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        toolbarMenu(server: server)
                    }
                }
            }
            else {
                ProgressView()
            }
        }
    }
    
    private var picker: some View {
        Picker("Server Detail Tab", selection: $activeTab) {
            ForEach(ServerDetailTab.allCases) { tab in
                Text(tab.localized())
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private func toolbarMenu(server: ServerData) -> some View {
        Menu("More", systemImage: "ellipsis") {
//            Section {
//                NavigationLink {
//                    TerminalView(server: server)
//                } label: {
//                    Label("Terminal", systemImage: "apple.terminal")
//                }
//            }
            
            Section {
                Button {
                    openWindow(id: "server-pin-view", value: server.id)
                } label: {
                    Label("Pin View", systemImage: "arrow.up.forward.and.arrow.down.backward")
                }
            }
        }
    }
    
    private func serverUnavailable(server: ServerData) -> some View {
        ContentUnavailableView("Server Unavailable", systemImage: "square.slash")
            .navigationTitle(server.name)
    }
}
