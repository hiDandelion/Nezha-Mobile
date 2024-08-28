//
//  MenuBarView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/14/24.
//

import SwiftUI

struct MenuBarView: View {
    @Bindable var dashboardViewModel: DashboardViewModel
    var serverID: String
    
    var body: some View {
        if let server = dashboardViewModel.servers.first(where: { String($0.id) == serverID }) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "circlebadge.fill")
                        .foregroundStyle(isServerOnline(timestamp: server.lastActive) || server.status.uptime == 0 ? .red : .green)
                    if server.host.countryCode.uppercased() != "" {
                        Text("\(countryFlagEmoji(countryCode: server.host.countryCode))\(server.name)")
                    }
                    else {
                        Text("🏴‍☠️\(server.name)")
                    }
                }
                
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
                .tint(.cyan)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        if let core = getCore(server.host.cpu) {
                            HStack {
                                Image(systemName: "cpu")
                                    .frame(width: 10)
                                Text("\(core) Core")
                            }
                        }
                        
                        HStack {
                            Image(systemName: "memorychip")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.memTotal))")
                        }
                        
                        HStack {
                            Image(systemName: "internaldrive")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.diskTotal))")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "network")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑\(formatBytes(server.status.netOutSpeed))/s")
                                Text("↓\(formatBytes(server.status.netInSpeed))/s")
                            }
                        }
                        
                        HStack {
                            Image(systemName: "circle.dotted.circle")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑\(formatBytes(server.status.netOutTransfer))")
                                Text("↓\(formatBytes(server.status.netInTransfer))")
                            }
                        }
                    }
                }
                .font(.caption2)
            }
            .padding()
        }
    }
}
