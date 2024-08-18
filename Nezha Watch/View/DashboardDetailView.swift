//
//  DashboardDetailView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct DashboardDetailView: View {
    var dashboardLink: String
    var dashboardAPIToken: String
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var servers: [(key: Int, value: Server)] = []
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
        NavigationStack {
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
                        ScrollView {
                            ForEach(sortedServers, id: \.id) { server in
                                NavigationLink(destination: ServerDetailView(server: server)) {
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
                                }
                            }
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
                    }
                case .error(let message):
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 5) {
                            Text("An error occurred")
                                .font(.headline)
                            Text(message)
                                .font(.subheadline)
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
        .onAppear {
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
