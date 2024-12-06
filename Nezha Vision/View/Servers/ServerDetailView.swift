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
    
    case basic = "Basic"
    case status = "Status"
    case ping = "Ping"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ServerDetailView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    var id: String
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
            if let server = dashboardViewModel.servers.first(where: { $0.id == id }) {
                if server.status.uptime != 0 {
                    VStack {
                        picker
                        form(server: server)
                    }
                    .navigationTitle(server.name)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            toolbarMenu(server: server)
                        }
                    }
                }
                else {
                    serverUnavailable(server: server)
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
    
    private func form(server: ServerData) -> some View {
        Form {
            switch(activeTab) {
            case .basic:
                Group {
                    ServerDetailBasicView(server: server)
                    ServerDetailHostView(server: server)
                }
                .tag(ServerDetailTab.basic)
            case .status:
                Group {
                    ServerDetailStatusView(server: server)
                }
                .tag(ServerDetailTab.status)
            case .ping:
                Group {
                    ServerDetailPingChartView(server: server)
                }
                .tag(ServerDetailTab.ping)
            }
        }
    }
    
    private func toolbarMenu(server: ServerData) -> some View {
        Menu {
            Section {
                Button {
                    Task {
                        await dashboardViewModel.refresh()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
                NavigationLink {
                    TerminalView(server: server)
                } label: {
                    Label("Terminal", systemImage: "apple.terminal")
                }
            }
            
            Section {
                Button {
                    openWindow(id: "server-pin-view", value: server.id)
                } label: {
                    Label("Pin View", systemImage: "arrow.up.forward.and.arrow.down.backward")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private func serverUnavailable(server: ServerData) -> some View {
        ContentUnavailableView("Server Unavailable", systemImage: "square.slash")
            .navigationTitle(server.name)
    }
}
