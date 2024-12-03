//
//  MenuBarView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/14/24.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @State private var selectedServerGroup: ServerGroup?
    
    private var filteredServers: [ServerData] {
        dashboardViewModel.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex < $1.displayIndex
            }
            .filter {
                if let selectedServerGroup {
                    return selectedServerGroup.serverIDs.contains($0.serverID)
                }
                else {
                    return true
                }
            }
    }
    
    var body: some View {
        VStack {
            HStack {
                Label("Servers", systemImage: "server.rack")
                Spacer()
                Button("Main Window") {
                    NSApp.setActivationPolicy(.regular)
                    openWindow(id: "main-view")
                }
            }
            .padding([.top, .horizontal])
            
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                Spacer()
                ProgressView("Loading...")
                Spacer()
            case .loaded:
                Picker("Tag", selection: $selectedServerGroup) {
                    Text("All")
                        .tag(nil as ServerGroup?)
                    ForEach(dashboardViewModel.serverGroups) { serverGroup in
                        Text(nameCanBeUntitled(serverGroup.name))
                            .tag(serverGroup)
                    }
                }
                .padding(.horizontal)
                serverList
            case .error(let message):
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 20) {
                        Text("An error occurred")
                            .font(.headline)
                        Text(message)
                            .font(.subheadline)
                        Button("Retry") {
                            dashboardViewModel.startMonitoring()
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            
            HStack {
                Button {
                    NSApp.terminate(self)
                } label: {
                    Label("Quit", systemImage: "escape")
                }
                Spacer()
                SettingsLink(label: {
                    Label("Settings", systemImage: "gearshape")
                })
            }
            .padding([.bottom, .horizontal])
        }
        .frame(width: 380, height: 700)
    }
    
    private var serverList: some View {
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                List {
                    ForEach(filteredServers) { server in
                        serverItem(server: server)
                        .id(server.id)
                        .contextMenu {
                            if server.ipv4 != "" {
                                Button("Copy IPv4") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(server.ipv4, forType: .string)
                                }
                            }
                            if server.ipv6 != "" {
                                Button("Copy IPv6") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(server.ipv6, forType: .string)
                                }
                            }
                            Divider()
                            Button("View Details") {
                                NSApp.setActivationPolicy(.regular)
                                openWindow(id: "server-detail-view", value: server.id)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
    
    private func serverItem(server: ServerData) -> some View {
        CardView {
            HStack {
                HStack {
                    HStack {
                        if server.countryCode.uppercased() != "" {
                            Text(countryFlagEmoji(countryCode: server.countryCode))
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
                    Spacer()
                    
                    HStack {
                        let cpuUsage = server.status.cpuUsed / 100
                        let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                        let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                        
                        VStack {
                            Gauge(value: cpuUsage) {
                                
                            } currentValueLabel: {
                                VStack {
                                    Text("CPU")
                                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("\(getCore(server.host.cpu) ?? 0) Core")
                                .font(.caption2)
                                .frame(minWidth: 50)
                                .lineLimit(1)
                        }
                        
                        VStack {
                            Gauge(value: memoryUsage) {
                                
                            } currentValueLabel: {
                                VStack {
                                    Text("MEM")
                                    Text("\(memoryUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("\(formatBytes(server.host.memoryTotal, decimals: 0))")
                                .font(.caption2)
                                .frame(minWidth: 50)
                                .lineLimit(1)
                        }
                        
                        VStack {
                            Gauge(value: diskUsage) {
                                
                            } currentValueLabel: {
                                VStack {
                                    Text("DISK")
                                    Text("\(diskUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("\(formatBytes(server.host.diskTotal, decimals: 0))")
                                .font(.caption2)
                                .frame(minWidth: 50)
                                .lineLimit(1)
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.blue)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "circle.dotted.circle")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.networkOut, decimals: 1))")
                                Text("↓ \(formatBytes(server.status.networkIn, decimals: 1))")
                            }
                        }
                        .frame(alignment: .leading)
                        
                        HStack {
                            Image(systemName: "network")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.networkOutSpeed, decimals: 1))/s")
                                Text("↓ \(formatBytes(server.status.networkInSpeed, decimals: 1))/s")
                            }
                        }
                        .frame(alignment: .leading)
                    }
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(minWidth: 100, alignment: .leading)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 10)
        }
    }
}
