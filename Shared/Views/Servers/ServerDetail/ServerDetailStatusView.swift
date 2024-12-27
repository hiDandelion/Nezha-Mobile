//
//  ServerDetailStatusView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailStatusView: View {
#if os(iOS)
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
#endif
    var server: ServerData
    
    var body: some View {
        Section {
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
                if server.host.swapTotal != 0 {
                    HStack {
                        Label("Swap", systemImage: "doc")
                        Spacer()
                        Text("\(formatBytes(server.status.swapUsed))/\(formatBytes(server.host.swapTotal))")
                            .foregroundStyle(.secondary)
                    }
                    
                    let swapUsage = Double(server.status.swapUsed) / Double(server.host.swapTotal)
                    Gauge(value: swapUsage) {
                        
                    }
                    .gaugeStyle(.linearCapacity)
                    .tint(gaugeGradient)
                }
                else {
                    NMUI.PieceOfInfo(systemImage: "doc", name: "Swap", content: Text("Disabled"))
                    
                    let swapUsage = 0.0
                    Gauge(value: swapUsage) {
                        
                    }
                    .gaugeStyle(.linearCapacity)
                    .tint(gaugeGradient)
                }
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
            
            NMUI.PieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Data", content: Text("↓ \(formatBytes(server.status.networkIn)) ↑ \(formatBytes(server.status.networkOut))"))
            NMUI.PieceOfInfo(systemImage: "network", name: "Network Send/Receive", content: Text("↓ \(formatBytes(server.status.networkInSpeed))/s ↑ \(formatBytes(server.status.networkOutSpeed))/s"))
            NMUI.PieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: Text("\(server.status.tcpConnectionCount)"))
            NMUI.PieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: Text("\(server.status.udpConnectionCount)"))
            NMUI.PieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: Text("\(server.status.processCount)"))
        }
#if os(iOS)
        .listRowBackground(theme.themeSecondaryColor(scheme: scheme))
#endif
    }
}
