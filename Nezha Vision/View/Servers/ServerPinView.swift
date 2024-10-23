//
//  ServerPinView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/23/24.
//

import SwiftUI

struct ServerPinView: View {
    var dashboardViewModel: DashboardViewModel
    @State var serverID: Int?
    
    var body: some View {
        Group {
            if let serverID, let server = dashboardViewModel.servers.first(where: { $0.id == serverID }) {
                VStack(spacing: 10) {
                    HStack {
                        HStack {
                            if server.host.countryCode.uppercased() == "TW" {
                                Text("🇹🇼")
                            }
                            else if server.host.countryCode.uppercased() != "" {
                                Text(countryFlagEmoji(countryCode: server.host.countryCode))
                            }
                            else {
                                Text("🏴‍☠️")
                            }
                        }
                        .frame(width: 20)
                        
                        Text(server.name)
                        
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: dashboardViewModel.lastUpdateTime ?? Date()) || server.status.uptime == 0 ? .red : .green)
                    }
                    
                    let gaugeGradient = Gradient(colors: [.green, .pink])
                    
                    VStack {
                        HStack {
                            Label("CPU", systemImage: "cpu")
                            Spacer()
                            Text("\(server.status.cpu, specifier: "%.2f")%")
                                .foregroundStyle(.secondary)
                        }
                        
                        let cpuUsage = server.status.cpu / 100
                        Gauge(value: cpuUsage) {
                            
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(gaugeGradient)
                    }
                    
                    VStack {
                        HStack {
                            Label("Memory", systemImage: "memorychip")
                            Spacer()
                            Text("\(formatBytes(server.status.memUsed))/\(formatBytes(server.host.memTotal))")
                                .foregroundStyle(.secondary)
                        }
                        
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        Gauge(value: memUsage) {
                            
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(gaugeGradient)
                    }
                    
                    VStack {
                        HStack {
                            Label("Disk", systemImage: "internaldrive")
                            Spacer()
                            Text("\(formatBytes(server.status.diskUsed))/\(formatBytes(server.host.diskTotal))")
                                .foregroundStyle(.secondary)
                        }
                        
                        let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                        Gauge(value: diskUsage) {
                            
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(gaugeGradient)
                    }
                    
                    HStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "circle.dotted.circle")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.netOutTransfer))")
                                Text("↓ \(formatBytes(server.status.netInTransfer))")
                            }
                        }
                        .frame(alignment: .leading)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "network")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.netOutSpeed))/s")
                                Text("↓ \(formatBytes(server.status.netInSpeed))/s")
                            }
                        }
                        .frame(alignment: .leading)
                        
                        Spacer()
                    }
                }
                .padding()
            }
            else {
                ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
        .onContinueUserActivity("drag") { userActivity in
            serverID = userActivity.userInfo?["serverID"] as? Int
        }
    }
}
