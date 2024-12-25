//
//  ServerCard.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/25/24.
//

import SwiftUI

struct ServerCard: View {
    let server: ServerData
    let lastUpdateTime: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    ServerTitle(server: server, lastUpdateTime: lastUpdateTime)
                        .font(.callout)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "power")
                        Text("\(formatTimeInterval(seconds: server.status.uptime))")
                    }
                    .font(.caption)
                }
                Spacer()
            }
            .padding(.top, 5)
            .padding(.horizontal, 10)
            
            VStack {
                ViewThatFits {
                    HStack {
                        gaugeView
                        
                        infoView
                            .font(.caption2)
                    }
                    
                    gaugeView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                HStack {
                    let totalCore = Double(getCore(server.host.cpu) ?? 1)
                    let loadPressure = server.status.load1 / totalCore
                    
                    Text("Load \(server.status.load1, specifier: "%.2f")")
                        .font(.caption2)
                    
                    Gauge(value: loadPressure <= 1 ? loadPressure : 1) {
                        
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                }
            }
            .padding(.bottom, 5)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }
    
    private var gaugeView: some View {
        HStack {
            let cpuUsage = server.status.cpuUsed / 100
            let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
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
                    .frame(minWidth: 60)
                    .lineLimit(1)
            }
            
            VStack {
                Gauge(value: memoryUsage) {
                    
                } currentValueLabel: {
                    VStack {
                        Text("MEM")
                        Text("\(memoryUsage * 100, specifier: "%.0f")%")
                    }
                }
                Text("\(formatBytes(server.host.memoryTotal, decimals: 0))")
                    .font(.caption2)
                    .frame(minWidth: 60)
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
                    .frame(minWidth: 60)
                    .lineLimit(1)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "circle.dotted.circle")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOut, decimals: 1))")
                    Text("↓ \(formatBytes(server.status.networkIn, decimals: 1))")
                }
            }
            .frame(alignment: .leading)
            
            HStack {
                Image(systemName: "network")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOutSpeed, decimals: 1))/s")
                    Text("↓ \(formatBytes(server.status.networkInSpeed, decimals: 1))/s")
                }
            }
            .frame(alignment: .leading)
        }
        .lineLimit(1)
        .frame(minWidth: 100)
    }
}
