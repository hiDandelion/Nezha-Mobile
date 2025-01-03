//
//  ServerDetailView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

enum ServerDetailTab: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case basic = "Basic"
    case status = "Status"
    case monitors = "Monitors"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ServerDetailView: View {
    @Environment(NMState.self) private var state
    var id: String
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
            if let server = state.servers.first(where: { $0.id == id }) {
                if server.status.uptime != 0 {
                    VStack {
                        switch(activeTab) {
                        case .basic:
                            Form {
                                ServerDetailBasicView(server: server)
                                ServerDetailHostView(server: server)
                            }
                            .formStyle(.grouped)
                            .tag(ServerDetailTab.basic)
                        case .status:
                            Form {
                                ServerDetailStatusView(server: server)
                            }
                            .formStyle(.grouped)
                            .tag(ServerDetailTab.status)
                        case .monitors:
                            Form {
                                ServerDetailPingChartView(server: server)
                            }
                            .formStyle(.grouped)
                            .tag(ServerDetailTab.monitors)
                        }
                    }
                    .navigationTitle("Server Details")
                    .navigationSubtitle(server.name)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Picker("Server Detail Tab", selection: $activeTab) {
                                ForEach(ServerDetailTab.allCases) { tab in
                                    Text(tab.localized())
                                        .tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        ToolbarItem {
                            toolbarMenu(server: server)
                        }
                    }
                }
                else {
                    ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                        .navigationTitle("Server Details")
                        .navigationSubtitle(server.name)
                }
            }
            else {
                ProgressView()
            }
        }
    }
    
    private func toolbarMenu(server: ServerData) -> some View {
        Menu {
            Section {
                Button {
                    Task {
                        await state.refreshServerAndServerGroup()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            Section {
                NavigationLink {
                    TerminalView(server: server)
                } label: {
                    Label("Terminal", systemImage: "apple.terminal")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
