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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                osCard
                cpuCard
                memoryCard
                diskCard
                networkCard
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func cardView<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        VStack(spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity)
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
    }
    
    private var osCard: some View {
        cardView {
            HStack {
                Text("OS")
                Spacer()
                Text(server.host.virtualization)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            
            HStack {
                let osName = server.host.platform
                let osVersion = server.host.platformVersion
                NMUI.getOSLogo(OSName: osName)
                Text(osName == "" ? String(localized: "Unknown") : "\(osName.capitalizeFirstLetter()) \(osVersion)")
            }
            .padding(.horizontal)
            
            HStack {
                Text("Load \(server.status.load1, specifier: "%.2f") \(server.status.load5, specifier: "%.2f") \(server.status.load15, specifier: "%.2f")")
                Spacer()
                Text("\(server.status.processCount) Processes")
            }
            .font(.caption)
            .padding(10)
        }
    }
    
    private var cpuCard: some View {
        cardView {
            HStack {
                Text("CPU")
                Spacer()
                Text(server.host.architecture)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            
            ForEach(server.host.cpu, id: \.self) { cpu in
                HStack {
                    NMUI.getCPULogo(CPUName: cpu)
                    Text(cpu)
                }
            }
            .padding(.horizontal)
            
            HStack {
                let cpuUsage = server.status.cpuUsed / 100
                Gauge(value: cpuUsage) {
                    
                }
                .gaugeStyle(.accessoryLinearCapacity)
                Text("\(cpuUsage * 100, specifier: "%.0f")%")
            }
            .font(.caption)
            .padding(10)
        }
    }
    
    private var memoryCard: some View {
        cardView {
            let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
            let swapUsage = Double(server.status.swapUsed) / Double(server.host.swapTotal)
            
            HStack {
                Text("Memory")
                Spacer()
                if server.host.swapTotal != 0 {
                    HStack(spacing: 5) {
                        Text("Swap")
                        Text("\(swapUsage * 100, specifier: "%.0f")%")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            
            HStack {
                Text(formatBytes(server.status.memoryUsed, decimals: 2))
                    .font(.title3)
                    .fontDesign(.rounded)
                Text("/")
                Text(formatBytes(server.host.memoryTotal))
                    .font(.title2)
                    .fontDesign(.rounded)
            }
            .padding(.horizontal)
            
            HStack {
                Gauge(value: memoryUsage) {
                    
                }
                .gaugeStyle(.accessoryLinearCapacity)
                Text("\(memoryUsage * 100, specifier: "%.0f")%")
            }
            .font(.caption)
            .padding(10)
        }
    }
    
    private var diskCard: some View {
        cardView {
            let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
            
            HStack {
                Text("Disk")
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            
            HStack {
                Text(formatBytes(server.status.diskUsed, decimals: 2))
                    .font(.title3)
                    .fontDesign(.rounded)
                Text("/")
                Text(formatBytes(server.host.diskTotal))
                    .font(.title2)
                    .fontDesign(.rounded)
            }
            .padding(.horizontal)
            
            HStack {
                Gauge(value: diskUsage) {
                    
                }
                .gaugeStyle(.accessoryLinearCapacity)
                Text("\(diskUsage * 100, specifier: "%.0f")%")
            }
            .font(.caption)
            .padding(10)
        }
    }
    
    private var networkCard: some View {
        cardView {
            HStack {
                Text("Network")
                Spacer()
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
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(10)
            
            VStack {
                Text(server.ipv4)
                Text(server.ipv6)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOut))")
                    Text("↓ \(formatBytes(server.status.networkIn))")
                }
                VStack(alignment: .leading) {
                    Text("↑ \(formatBytes(server.status.networkOutSpeed))/s")
                    Text("↓ \(formatBytes(server.status.networkInSpeed))/s")
                }
            }
            .font(.title3)
            .fontDesign(.rounded)
            .padding(.horizontal)
            
            HStack {
                HStack(spacing: 5) {
                    Text("TCP")
                    Text("\(server.status.tcpConnectionCount)")
                }
                HStack(spacing: 5) {
                    Text("UDP")
                    Text("\(server.status.udpConnectionCount)")
                }
                Spacer()
            }
            .font(.caption)
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
