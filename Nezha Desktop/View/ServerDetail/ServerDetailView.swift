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
                        case .ping:
                            Form {
                                ServerDetailPingChartView(server: server)
                            }
                            .formStyle(.grouped)
                            .tag(ServerDetailTab.ping)
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
        .onAppear {
            if !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
        .onOpenURL { url in
            _ = debugLog("Incoming Link Info - App was opened via URL: \(url)")
            handleIncomingURL(url)
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nezha" else {
            _ = debugLog("Incoming Link Error - Invalid Scheme")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            _ = debugLog("Incoming Link Error - Invalid URL")
            return
        }
        
        guard let action = components.host, action == "server-details" else {
            _ = debugLog("Incoming Link Error - Unknown action")
            return
        }
        
        guard let serverID = components.queryItems?.first(where: { $0.name == "serverID" })?.value else {
            _ = debugLog("Incoming Link Error - Server ID not found")
            return
        }
        
        openWindow(value: serverID)
    }
}
