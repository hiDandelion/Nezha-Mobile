//
//  MenuBarView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/14/24.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow
    @AppStorage("NMDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardAPIToken: String = ""
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
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
            case .loaded:
                VStack {
                    VStack {
                        HStack {
                            Label("Servers", systemImage: "server.rack")
                            Spacer()
                            Button("Main Window") {
                                openWindow(id: "main-view")
                            }
                        }
                        Picker("Tag", selection: $activeTag) {
                            ForEach(allTags, id: \.self) { tag in
                                Text(tag == "All" ? String(localized: "All(\(dashboardViewModel.servers.count))") : (tag == "" ? String(localized: "Uncategorized") : tag))
                                    .id(tag)
                            }
                        }
                    }
                    .padding([.top, .horizontal])
                    serverList
                    HStack {
                        Spacer()
                        SettingsLink(label: {
                            Label("Settings", systemImage: "gearshape")
                        })
                    }
                    .padding([.bottom, .horizontal])
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
        .frame(width: 380, height: 810)
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
                                openWindow(value: server.id)
                            }
                        }
                    }
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
