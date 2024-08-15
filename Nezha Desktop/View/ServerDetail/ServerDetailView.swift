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
    var server: Server
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
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
                .animation(.easeInOut(duration: 0.3), value: activeTab)
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
    }
}
