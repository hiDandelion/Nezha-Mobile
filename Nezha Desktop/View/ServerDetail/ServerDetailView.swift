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
    
    case status = "Status"
    case monitors = "Monitors"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ServerDetailView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) private var state
    var id: String
    @State private var activeTab: ServerDetailTab = .status
    
    var body: some View {
        NavigationStack {
            if let server = state.servers.first(where: { $0.id == id }) {
                VStack {
                    if server.status.uptime != 0 {
                        content(server: server)
                    }
                    else {
                        ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                            .navigationTitle("Server Details")
                            .navigationSubtitle(server.name)
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
                ProgressView()
            }
        }
    }
    
    private func content(server: ServerData) -> some View {
        ZStack {
            theme.themeBackgroundColor(scheme: scheme)
                .ignoresSafeArea()
            
            switch(activeTab) {
            case .status:
                ServerDetailStatusView(server: server)
                    .tag(ServerDetailTab.status)
            case .monitors:
                ServerDetailPingChartView(server: server)
                    .tag(ServerDetailTab.monitors)
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
