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
    @State private var selectedServers: Set<Server.ID> = Set<Server.ID>()
    
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
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        Table(of: Server.self, selection: $selectedServers) {
            TableColumn("Name") { server in
                HStack {
                    if let lastUpdateTime = dashboardViewModel.lastUpdateTime {
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: lastUpdateTime) || server.status.uptime == 0 ? .red : .green)
                    }
                    if server.host.countryCode.uppercased() != "" {
                        Text("\(countryFlagEmoji(countryCode: server.host.countryCode))\(server.name)")
                    }
                    else {
                        Text("🏴‍☠️\(server.name)")
                    }
                }
            }
            TableColumn("Tag", value: \.tag)
            TableColumn("CPU") { server in
                let cpuUsage = server.status.cpu / 100
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
                let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                HStack {
                    Text("\(memUsage * 100, specifier: "%.0f")%")
                        .font(.system(size: 12))
                        .frame(minWidth: 30)
                    Gauge(value: memUsage) {
                        
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
        .contextMenu(forSelectionType: Server.ID.self) { items in
            
        } primaryAction: { serverIDs in
            for serverID in serverIDs {
                openWindow(id: "server-detail-view", value: serverID)
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
}
