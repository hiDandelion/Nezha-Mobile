//
//  ServerPinView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/23/24.
//

import SwiftUI

struct ServerPinView: View {
    var id: String
    var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        Group {
            if let server = dashboardViewModel.servers.first(where: { $0.id == id }) {
                content(server: server)
            }
            else {
                ProgressView("Loading...")
            }
        }
    }
    
    private func content(server: ServerData) -> some View {
        VStack(spacing: 10) {
            title(server: server)
            gauges(server: server)
            networkStatus(server: server)
        }
        .padding()
    }
    
    private func title(server: ServerData) -> some View {
        HStack {
            HStack {
                if server.countryCode.uppercased() == "TW" {
                    Text("🇹🇼")
                }
                else if server.countryCode.uppercased() != "" {
                    Text(countryFlagEmoji(countryCode: server.countryCode))
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
    }
    
    private func gauges(server: ServerData) -> some View {
        VStack {
            let gaugeGradient = Gradient(colors: [.green, .pink])
            
            VStack {
                HStack {
                    Label("CPU", systemImage: "cpu")
                    Spacer()
                    Text("\(server.status.cpuUsed, specifier: "%.2f")%")
                        .foregroundStyle(.secondary)
                }
                
                let cpuUsage = server.status.cpuUsed / 100
                Gauge(value: cpuUsage) {
                    
                }
                .gaugeStyle(.linearCapacity)
                .tint(gaugeGradient)
            }
            
            VStack {
                HStack {
                    Label("Memory", systemImage: "memorychip")
                    Spacer()
                    Text("\(formatBytes(server.status.memoryUsed))/\(formatBytes(server.host.memoryTotal))")
                        .foregroundStyle(.secondary)
                }
                
                let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                Gauge(value: memoryUsage) {
                    
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
        }
    }
    
    private func networkStatus(server: ServerData) -> some View {
        HStack {
            Spacer()
            
            HStack {
                Image(systemName: "circle.dotted.circle")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOut))")
                    Text("↓ \(formatBytes(server.status.networkIn))")
                }
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            HStack {
                Image(systemName: "network")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOutSpeed))/s")
                    Text("↓ \(formatBytes(server.status.networkInSpeed))/s")
                }
            }
            .frame(alignment: .leading)
            
            Spacer()
        }
    }
}
