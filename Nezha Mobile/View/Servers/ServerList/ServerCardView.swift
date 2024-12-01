//
//  ServerCardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/18/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerCardView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeStore.self) var themeStore
    @AppStorage("NMTheme", store: NMCore.userDefaults) private var theme: NMTheme = .blue
    let lastUpdateTime: Date?
    let server: ServerData
    
    var body: some View {
        CardView {
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
        } contentView: {
            VStack {
                ViewThatFits {
                    HStack {
                        gaugeView
                        
                        infoView
                            .font(.caption2)
                    }
                    
                    gaugeView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .tint(themeStore.themeCustomizationEnabled ? themeStore.themeTintColor(scheme: scheme) : themeColor(theme: theme))
            }
        }
        .if(themeStore.themeCustomizationEnabled) { view in
            view.foregroundStyle(themeStore.themePrimaryColor(scheme: scheme))
        }
        .if(themeStore.themeCustomizationEnabled) { view in
            view.background(themeStore.themeSecondaryColor(scheme: scheme))
        }
        .if(!themeStore.themeCustomizationEnabled) { view in
            view.background(.thinMaterial)
        }
        .cornerRadius(12)
        .contextMenu(ContextMenu(menuItems: {
            if server.ipv4 != "" {
                Button {
                    UIPasteboard.general.string = server.ipv4
                } label: {
                    Label("Copy IPv4", systemImage: "4.circle")
                }
            }
            if server.ipv6 != "" {
                Button {
                    UIPasteboard.general.string = server.ipv6
                } label: {
                    Label("Copy IPv6", systemImage: "6.circle")
                }
            }
        }))
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
        .tint(themeStore.themeCustomizationEnabled ? themeStore.themeTintColor(scheme: scheme) : themeColor(theme: theme))
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
