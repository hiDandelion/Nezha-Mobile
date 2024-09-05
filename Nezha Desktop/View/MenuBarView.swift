//
//  MenuBarView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/14/24.
//

import SwiftUI

struct MenuBarView: View {
    @AppStorage("NMDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardAPIToken: String = ""
    var dashboardViewModel: DashboardViewModel
    
    private var filteredServers: [Server] {
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
                ProgressView("Loading...")
            case .loaded:
                ScrollView {
                    HStack {
                        Label("Servers", systemImage: "server.rack")
                        Spacer()
                    }
                    .padding([.top, .leading])
                    serverList
                        .padding(.bottom)
                }
            case .error(let message):
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 20) {
                        Text("An error occurred")
                            .font(.headline)
                        Text(message)
                            .font(.subheadline)
                        Button("Retry") {
                            dashboardViewModel.startMonitoring()
                        }
                        SettingsLink(label: {
                            Text("Settings")
                        })
                    }
                    .padding()
                }
            }
        }
        .frame(width: 380, height: 800)
        .onAppear {
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
    
    private var serverList: some View {
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                VStack(spacing: 10) {
                    Divider()
                    ForEach(filteredServers) { server in
                        ServerCard(server: server)
                        .id(server.id)
                        Divider()
                    }
                }
                .padding(.horizontal, 15)
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
    
    private func ServerCard(server: Server) -> some View {
        CardView {
            HStack {
                HStack {
                    HStack {
                        if server.host.countryCode.uppercased() != "" {
                            Text(countryFlagEmoji(countryCode: server.host.countryCode))
                        }
                        else {
                            Text("🏴‍☠️")
                        }
                    }
                    .frame(width: 20)
                    Text(server.name)
                    if let lastUpdateTime = dashboardViewModel.lastUpdateTime {
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: lastUpdateTime) || server.status.uptime == 0 ? .red : .green)
                    }
                }
                .font(.callout)
                
                Spacer()
                
                HStack {
                    Image(systemName: "power")
                    Text("\(formatTimeInterval(seconds: server.status.uptime))")
                }
                .font(.caption)
            }
        } contentView: {
            VStack {
                HStack {
                    HStack {
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                        
                        Gauge(value: cpuUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("CPU")
                                Text("\(cpuUsage * 100, specifier: "%.0f")%")
                            }
                        }
                        
                        Gauge(value: memUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("MEM")
                                Text("\(memUsage * 100, specifier: "%.0f")%")
                            }
                        }
                        
                        Gauge(value: diskUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("DISK")
                                Text("\(diskUsage * 100, specifier: "%.0f")%")
                            }
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.blue)
                    
                    VStack(alignment: .leading) {
                        if let core = getCore(server.host.cpu) {
                            HStack {
                                Image(systemName: "cpu")
                                    .frame(width: 10)
                                Text("\(core) Core")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            Image(systemName: "memorychip")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.memTotal))")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "internaldrive")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.diskTotal))")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "network")
                                    .frame(width: 10)
                                VStack(alignment: .leading) {
                                    Text("↑\(formatBytes(server.status.netOutSpeed))/s")
                                    Text("↓\(formatBytes(server.status.netInSpeed))/s")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                    }
                    .font(.caption2)
                    .frame(maxWidth: 100)
                    .padding(.leading, 20)
                }
            }
        }
    }
}
