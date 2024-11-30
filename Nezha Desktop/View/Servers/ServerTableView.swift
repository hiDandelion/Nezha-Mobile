//
//  ServerTableView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/21/24.
//

import SwiftUI

struct ServerTableView: View {
    @Environment(\.openWindow) var openWindow
    @Bindable var dashboardViewModel: DashboardViewModel
    var activeTag: String = "All"
    @State private var searchText: String = ""
    @State private var selectedServers: Set<ServerData.ID> = Set<ServerData.ID>()
    
    private var filteredServers: [ServerData] {
        dashboardViewModel.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex < $1.displayIndex
            }
            .filter { activeTag == "All" || $0.tag == activeTag }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        table
            .contextMenu(forSelectionType: ServerData.ID.self) { items in
                
            } primaryAction: { ids in
                for id in ids {
                    openWindow(id: "server-detail-view", value: id)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Servers(\(dashboardViewModel.servers.count))")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        openWindow(id: "map-view")
                    } label: {
                        Label("Map View", systemImage: "map")
                    }
                }
            }
    }
    
    private var table: some View {
        Table(of: ServerData.self, selection: $selectedServers) {
            TableColumn("Name") { server in
                HStack {
                    if let lastUpdateTime = dashboardViewModel.lastUpdateTime {
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: lastUpdateTime) || server.status.uptime == 0 ? .red : .green)
                    }
                    if server.countryCode.uppercased() != "" {
                        Text("\(countryFlagEmoji(countryCode: server.countryCode))\(server.name)")
                    }
                    else {
                        Text("🏴‍☠️\(server.name)")
                    }
                }
            }
            TableColumn("Tag", value: \.tag)
            TableColumn("CPU") { server in
                let cpuUsage = server.status.cpuUsed / 100
                HStack {
                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                        .font(.system(size: 12))
                        .frame(minWidth: 30)
                    Gauge(value: cpuUsage) {
                        
                    }
                    .gaugeStyle(LinearCapacityGaugeStyle())
                }
            }
            TableColumn("Memory") { server in
                let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                HStack {
                    Text("\(memoryUsage * 100, specifier: "%.0f")%")
                        .font(.system(size: 12))
                        .frame(minWidth: 30)
                    Gauge(value: memoryUsage) {
                        
                    }
                    .gaugeStyle(LinearCapacityGaugeStyle())
                }
            }
            TableColumn("Swap") { server in
                let swapUsage = (server.host.swapTotal == 0 ? 0 : Double(server.status.swapUsed) / Double(server.host.swapTotal))
                HStack {
                    Text("\(swapUsage * 100, specifier: "%.0f")%")
                        .font(.system(size: 12))
                        .frame(minWidth: 30)
                    Gauge(value: swapUsage) {
                        
                    }
                    .gaugeStyle(LinearCapacityGaugeStyle())
                }
            }
            TableColumn("Disk") { server in
                let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                HStack {
                    Text("\(diskUsage * 100, specifier: "%.0f")%")
                        .font(.system(size: 12))
                        .frame(minWidth: 30)
                    Gauge(value: diskUsage) {
                        
                    }
                    .gaugeStyle(LinearCapacityGaugeStyle())
                }
            }
            TableColumn("Up Time") { server in
                Text(formatTimeInterval(seconds: server.status.uptime))
            }
        } rows: {
            ForEach(filteredServers, id: \.id) { server in
                TableRow(server)
                    .contextMenu {
                        if server.ipv4 != "" {
                            Button("Copy IPv4") {
                                NSPasteboard.general.setString(server.ipv4, forType: .string)
                            }
                        }
                        if server.ipv6 != "" {
                            Button("Copy IPv6") {
                                NSPasteboard.general.setString(server.ipv6, forType: .string)
                            }
                        }
                        Divider()
                        Button("View Details") {
                            openWindow(id: "server-detail-view", value: server.id)
                        }
                    }
            }
        }
    }
}
