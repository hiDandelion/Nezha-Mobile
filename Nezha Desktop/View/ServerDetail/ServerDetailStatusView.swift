//
//  ServerDetailStatusView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailStatusView: View {
    var server: Server
    
    var body: some View {
        Section("Status") {
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
                }
                else {
                    PieceOfInfo(systemImage: "doc", name: "Swap", content: Text(String(localized: "Disabled")))
                    
                    let swapUsage = 0.0
                    Gauge(value: swapUsage) {
                        
                    }
                    .gaugeStyle(.linearCapacity)
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
            }
            
            PieceOfInfo(systemImage: "network", name: "Network Send/Receive", content: Text("↓ \(formatBytes(server.status.netInSpeed))/s ↑ \(formatBytes(server.status.netOutSpeed))/s"))
            PieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Data", content: Text("↓ \(formatBytes(server.status.netInTransfer)) ↑ \(formatBytes(server.status.netOutTransfer))"))
            PieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: Text("\(server.status.TCPConnectionCount)"))
            PieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: Text("\(server.status.UDPConnectionCount)"))
            PieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: Text("\(server.status.processCount)"))
        }
    }
}
