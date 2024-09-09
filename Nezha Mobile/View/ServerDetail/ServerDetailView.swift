//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import Charts

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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    var serverID: Int
    var dashboardViewModel: DashboardViewModel
    var themeStore: ThemeStore
    @State private var selectedSection: Int = 0
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
            ZStack {
                if themeStore.themeCustomizationEnabled {
                    themeStore.themeBackgroundColor(scheme: scheme)
                        .ignoresSafeArea()
                }
                else {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                }
                if let server = dashboardViewModel.servers.first(where: { $0.id == serverID }) {
                    VStack {
                        if server.status.uptime != 0 {
                            Form {
                                ServerDetailBasicView(server: server)
                                ServerDetailHostView(server: server)
                                ServerDetailStatusView(server: server)
                                ServerDetailPingChartView(server: server)
                            }
                            .scrollContentBackground(.hidden)
                        }
                        else {
                            ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                        }
                    }
                    .navigationTitle(server.name)
                    .navigationBarTitleDisplayMode(.inline)
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
                                    if server.IPv4 != "" {
                                        NavigationLink(destination: PrepareConnectionView(host: server.IPv4)) {
                                            Label("Connect via IPv4", systemImage: "link")
                                        }
                                    }
                                    if server.IPv6 != "" {
                                        NavigationLink(destination: PrepareConnectionView(host: server.IPv4)) {
                                            Label("Connect via IPv6", systemImage: "link")
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            if !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
