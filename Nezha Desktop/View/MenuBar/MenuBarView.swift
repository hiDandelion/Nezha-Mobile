//
//  MenuBarView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/14/24.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow
    @AppStorage("NMDashboardLink", store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: NMCore.userDefaults) private var dashboardAPIToken: String = ""
    var dashboardViewModel: DashboardViewModel
    @State private var activeTag: String = "All"
    
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
            .filter { activeTag == "All" || $0.tag == activeTag }
    }
    
    private var tags: [String] {
        Array(Set(dashboardViewModel.servers.map { $0.tag }))
    }
    
    private var allTags: [String] {
        ["All"] + tags.sorted()
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
                Picker("Tag", selection: $activeTag) {
                    ForEach(allTags, id: \.self) { tag in
                        Text(tag == "All" ? String(localized: "All(\(dashboardViewModel.servers.count))") : (tag == "" ? String(localized: "Uncategorized") : tag))
                            .id(tag)
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
        .onAppear {
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
    
    private var serverList: some View {
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                List {
                    ForEach(filteredServers) { server in
                        ServerCard(server: server)
                        .id(server.id)
                        .contextMenu {
                            if server.IPv4 != "" {
                                Button("Copy IPv4") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(server.IPv4, forType: .string)
                                }
                            }
                            if server.IPv6 != "" {
                                Button("Copy IPv6") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(server.IPv6, forType: .string)
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
                    Spacer()
                    
                    HStack {
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
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
                            Gauge(value: memUsage) {
                                
                            } currentValueLabel: {
                                VStack {
                                    Text("MEM")
                                    Text("\(memUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("\(formatBytes(server.host.memTotal, decimals: 0))")
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
                                Text("↑ \(formatBytes(server.status.netOutTransfer))")
                                Text("↓ \(formatBytes(server.status.netInTransfer))")
                            }
                        }
                        .frame(alignment: .leading)
                        
                        HStack {
                            Image(systemName: "network")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.netOutSpeed))/s")
                                Text("↓ \(formatBytes(server.status.netInSpeed))/s")
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
