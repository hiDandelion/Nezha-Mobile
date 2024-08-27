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
                .gaugeStyle(AccessoryLinearGaugeStyle())
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
                .gaugeStyle(AccessoryLinearGaugeStyle())
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
                    .gaugeStyle(AccessoryLinearGaugeStyle())
                    .tint(gaugeGradient)
                }
                else {
                    pieceOfInfo(systemImage: "doc", name: "Swap", content: String(localized: "Disabled"))
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
                .gaugeStyle(AccessoryLinearGaugeStyle())
                .tint(gaugeGradient)
            }
            
            pieceOfInfo(systemImage: "network", name: "Network", content: "↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s")
            pieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Traffic", content: "↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))")
            pieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: "\(server.status.TCPConnectionCount)")
            pieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: "\(server.status.UDPConnectionCount)")
            pieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: "\(server.status.processCount)")
        }
    }
}
