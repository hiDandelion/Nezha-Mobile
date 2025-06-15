//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
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
    @Environment(NMState.self) var state
    var id: String
    @State private var selectedSection: Int = 0
    @State private var activeTab: ServerDetailTab = .status
    
    var body: some View {
        if let server = state.servers.first(where: { $0.id == id }) {
            VStack {
                if server.status.uptime != 0 {
                    content(server: server)
                }
                else {
                    ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    terminalButton(server: server)
                }
                ToolbarSpacer(.fixed)
                ToolbarItem {
                    refreshButton
                }
            }
        }
        else {
            ProgressView()
        }
    }
    
    private func terminalButton(server: ServerData) -> some View {
        NavigationLink {
            TerminalView(server: server)
        } label: {
            Label("Terminal", systemImage: "apple.terminal")
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await state.refreshServerAndServerGroup()
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
    }
    
    private func content(server: ServerData) -> some View {
        ZStack {
            theme.themeBackgroundColor(scheme: scheme)
                .ignoresSafeArea()
            
            VStack {
                Picker("Section", selection: $activeTab) {
                    ForEach(ServerDetailTab.allCases) {
                        Text($0.localized())
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                switch(activeTab) {
                case .status:
                    ServerDetailStatusView(server: server)
                case .monitors:
                    ServerDetailPingChartView(server: server)
                }
            }
        }
    }
}
