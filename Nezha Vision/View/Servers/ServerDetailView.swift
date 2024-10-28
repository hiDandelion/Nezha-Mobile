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
    @Bindable var dashboardViewModel: DashboardViewModel
    var serverID: Int
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
            if let server = dashboardViewModel.servers.first(where: { $0.id == serverID }) {
                if server.status.uptime != 0 {
                    VStack {
                        Picker("Server Detail Tab", selection: $activeTab) {
                            ForEach(ServerDetailTab.allCases) { tab in
                                Text(tab.localized())
                                    .tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
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
                    .navigationTitle(server.name)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Menu {
                                Section {
                                    Button {
                                        dashboardViewModel.updateImmediately()
                                    } label: {
                                        Label("Refresh", systemImage: "arrow.clockwise")
                                    }
                                }
                                
                                Section {
                                    Button {
                                        openWindow(id: "main-view")
                                    } label: {
                                        Label("Main View", systemImage: "house")
                                    }
                                    
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
                    }
                }
                else {
                    ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                        .navigationTitle(server.name)
                }
            }
            else {
                ProgressView()
            }
        }
        .onAppear {
            if !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
