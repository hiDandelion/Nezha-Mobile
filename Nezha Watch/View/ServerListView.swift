//
//  ServerListView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ServerListView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var selectedServer: ServerData?
    @State private var isShowingErrorDetailAlert: Bool = false
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    
    private var sortedServers: [ServerData] {
        dashboardViewModel.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex > $1.displayIndex
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
                                CountryFlag(countryCode: server.countryCode)
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
    }
}
