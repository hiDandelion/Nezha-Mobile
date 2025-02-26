//
//  ServerDetailStatusView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailStatusView: View {
#if os(iOS) || os(macOS)
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
#endif
    var server: ServerData
    
    private let columns: [GridItem] = [.init(.flexible()), .init(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                osCard
                cpuCard
                memoryCard
                diskCard
                networkCard
                networkDataCard
                networkAddressCard
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func cardView<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: 16)
                #if os(iOS) || os(macOS)
                    .fill(theme.themeSecondaryColor(scheme: scheme))
                #endif
                #if os(visionOS)
                    .fill(.thinMaterial)
                #endif
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
            )
            .frame(maxWidth: .infinity)
            .frame(height: 180)
    }
    
    private var osCard: some View {
        cardView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "opticaldisc")
                        Text("OS")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    let osName = server.host.platform
                    let osVersion = server.host.platformVersion
                    NMUI.getOSLogo(OSName: osName)
                    Text(osName == "" ? String(localized: "Unknown") : "\(osName.capitalizeFirstLetter()) \(osVersion)")
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Load \(server.status.load1, specifier: "%.2f") \(server.status.load5, specifier: "%.2f") \(server.status.load15, specifier: "%.2f")")
                        Text("Processes \(server.status.processCount)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(10)
        }
    }
    
    private var cpuCard: some View {
        cardView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "cpu")
                        Text("CPU")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    if let cpuName = server.host.cpu.first {
                        NMUI.getCPULogo(CPUName: cpuName)
                        Text(cpuName)
                            .font(.caption)
                            .lineLimit(2)
                    }
                    else {
                        Text("Unknown")
                    }
                }
                
                Spacer()
                
                HStack {
                    let cpuUsage = server.status.cpuUsed / 100
                    Gauge(value: cpuUsage) {
                        
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                }
                .font(.caption)
            }
            .padding(10)
        }
    }
    
    private var memoryCard: some View {
        cardView {
            VStack {
                let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                
                HStack {
                    HStack {
                        Image(systemName: "memorychip")
                        Text("Memory")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Gauge(value: memoryUsage) {
                        Text("\(memoryUsage * 100, specifier: "%.0f")%")
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.accentColor)
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Used \(formatBytes(server.status.memoryUsed))")
                        Text("Total \(formatBytes(server.host.memoryTotal))")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(10)
        }
    }
    
    private var diskCard: some View {
        cardView {
            VStack {
                let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                
                HStack {
                    HStack {
                        Image(systemName: "internaldrive")
                        Text("Disk")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Gauge(value: diskUsage) {
                        Text("\(diskUsage * 100, specifier: "%.0f")%")
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.accentColor)
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Used \(formatBytes(server.status.diskUsed))")
                        Text("Total \(formatBytes(server.host.diskTotal))")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(10)
        }
    }
    
    private var networkCard: some View {
        cardView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "network")
                        Text("Network Send/Receive")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOutSpeed))/s")
                    Text("↓ \(formatBytes(server.status.networkInSpeed))/s")
                }
                
                Spacer()
                
                HStack {
                    HStack {
                        Text("TCP \(server.status.tcpConnectionCount)")
                        Text("UDP \(server.status.udpConnectionCount)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(10)
        }
    }
    
    private var networkDataCard: some View {
        cardView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "arrow.up.left.arrow.down.right")
                        Text("Network Data")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOut))")
                    Text("↓ \(formatBytes(server.status.networkIn))")
                }
                
                Spacer()
            }
            .padding(10)
        }
    }
    
    private var networkAddressCard: some View {
        cardView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "pin.circle")
                        Text("IP Address")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    CountryFlag(countryCode: server.countryCode)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    if server.ipv4 != "" {
                        HStack {
                            Image(systemName: "4.circle")
                            Text(server.ipv4)
                        }
                        .lineLimit(1)
                    }
                    if server.ipv6 != "" {
                        HStack {
                            Image(systemName: "6.circle")
                            Text(server.ipv6)
                                .font(.caption)
                        }
                        .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(10)
        }
        .contextMenu {
            if server.ipv4 != "" {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = server.ipv4
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(server.ipv4, forType: .string)
#endif
                } label: {
                    Label("Copy IPv4", systemImage: "4.circle")
                }
            }
            if server.ipv6 != "" {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = server.ipv6
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(server.ipv6, forType: .string)
#endif
                } label: {
                    Label("Copy IPv6", systemImage: "6.circle")
                }
            }
            
        }
    }
}
