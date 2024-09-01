//
//  ServerListView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ServerListView: View {
    var dashboardLink: String
    var dashboardAPIToken: String
    var dashboardViewModel: DashboardViewModel
    @State private var selectedServer: Server?
    @State private var isShowingErrorDetailAlert: Bool = false
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    
    private var sortedServers: [Server] {
        dashboardViewModel.servers
            .sorted { server1, server2 in
                switch (server1.displayIndex, server2.displayIndex) {
                case (.none, .none):
                    return server1.id < server2.id
                case (.none, .some):
                    return false
                case (.some, .none):
                    return true
                case let (.some(index1), .some(index2)):
                    return index1 > index2 || (index1 == index2 && server1.id < server2.id)
                }
            }
    }
    
    var body: some View {
        VStack {
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded:
                if dashboardViewModel.servers.isEmpty {
                    ProgressView()
                }
                else {
                    NavigationSplitView {
                        List(sortedServers, selection: $selectedServer) { server in
                            HStack {
                                if server.host.countryCode.uppercased() == "TW" {
                                    Image("TWFlag")
                                        .resizable()
                                        .scaledToFit()
                                }
                                else if server.host.countryCode.uppercased() != "" {
                                    Text(countryFlagEmoji(countryCode: server.host.countryCode))
                                }
                                else {
                                    Text("🏴‍☠️")
                                }
                                Text(server.name)
                            }
                            .tag(server)
                        }
                        .navigationTitle("Dashboard")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    isShowingSettingSheet = true
                                } label: {
                                    Label("Settings", systemImage: "gear")
                                }
                            }
                        }
                    } detail: {
                        if let selectedServer {
                            ServerDetailView(server: selectedServer)
                        }
                        else {
                            ContentUnavailableView("No Server", systemImage: "square.3.stack.3d.slash")
                        }
                    }
                }
            case .error(let message):
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 5) {
                        Button {
                            isShowingErrorDetailAlert = true
                        } label: {
                            Text("An error occurred")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alert(message, isPresented: $isShowingErrorDetailAlert) {
                            Button("OK", role: .cancel) {
                                isShowingErrorDetailAlert = false
                            }
                        }
                        
                        Spacer()
                        
                        Button("Retry") {
                            dashboardViewModel.startMonitoring()
                        }
                        Button("Settings") {
                            isShowingSettingSheet.toggle()
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingSettingSheet) {
            SettingView(dashboardViewModel: dashboardViewModel)
        }
        .onAppear {
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
