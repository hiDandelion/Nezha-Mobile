//
//  ServerDetailView.swift
//  Nezha Mobile Mac
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
}

struct ServerDetailView: View {
    var server: Server
    @State private var activeTab: ServerDetailTab = .basic
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Server Detail")
            .navigationSubtitle(server.name)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Server Detail Tab", selection: $activeTab) {
                        ForEach(ServerDetailTab.allCases) { tab in
                            Text(tab.rawValue)
                                .tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}
