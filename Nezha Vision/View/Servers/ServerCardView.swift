//
//  ServerCardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerCardView: View {
    @Environment(\.colorScheme) private var scheme
    let lastUpdateTime: Date?
    let server: Server
    
    var body: some View {
        CardView {
            HStack {
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
                    
                    if let lastUpdateTime {
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
                    Spacer()
                    
                    HStack {
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
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
                                .frame(minWidth: 50)
                                .lineLimit(1)
                        }
                        
                        VStack {
                            Gauge(value: memUsage) {
                                
                            } currentValueLabel: {
                                VStack {
                                    Text("MEM")
                                    Text("\(memUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("\(formatBytes(server.host.memTotal, decimals: 0))")
                                .font(.caption2)
                                .frame(minWidth: 50)
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
                                .frame(minWidth: 50)
                                .lineLimit(1)
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "circle.dotted.circle")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.netOutTransfer))")
                                Text("↓ \(formatBytes(server.status.netInTransfer))")
                            }
                        }
                        .frame(alignment: .leading)
                        
                        HStack {
                            Image(systemName: "network")
                                .frame(width: 10)
                            VStack(alignment: .leading) {
                                Text("↑ \(formatBytes(server.status.netOutSpeed))/s")
                                Text("↓ \(formatBytes(server.status.netInSpeed))/s")
                            }
                        }
                        .frame(alignment: .leading)
                    }
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(minWidth: 100, alignment: .leading)
                    
                    Spacer()
                }
            }
        } footerView: {
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
        .background(.thinMaterial)
        .cornerRadius(12)
        .contextMenu(ContextMenu(menuItems: {
            if server.IPv4 != "" {
                Button {
                    UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy IPv4", systemImage: "4.circle")
                }
            }
            if server.IPv6 != "" {
                Button {
                    UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy IPv6", systemImage: "6.circle")
                }
            }
        }))
    }
}
