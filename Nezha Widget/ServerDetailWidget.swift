//
//  ServerDetailWidget.swift
//  Nezha Widget
//
//  Created by Junhui Lou on 8/2/24.
//

import WidgetKit
import SwiftUI

struct ServerDetailProvider: AppIntentTimelineProvider {
    typealias Entry = ServerEntry
    
    typealias Intent = ServerDetailConfigurationIntent
    
    func placeholder(in context: Context) -> ServerEntry {
        ServerEntry(
            date: Date(),
            server: ServerData(
                id: UUID().uuidString,
                serverID: 0,
                name: "Demo",
                tag: "Group",
                displayIndex: 0,
                lastActive: Date(),
                ipv4: "255.255.255.255",
                ipv6: "::1",
                countryCode: "us",
                host: ServerData.Host(
                    platform: "debian",
                    platformVersion: "12",
                    cpu: ["Intel 4 Virtual Core"],
                    memoryTotal: 1024000,
                    swapTotal: 1024000,
                    diskTotal: 1024000,
                    architecture: "x86_64",
                    virtualization: "kvm",
                    bootTime: 0
                ),
                status: ServerData.Status(
                    cpuUsed: 100,
                    memoryUsed: 1024000,
                    swapUsed: 1024000,
                    diskUsed: 1024000,
                    networkIn: 1024000,
                    networkOut: 1024000,
                    networkInSpeed: 1024000,
                    networkOutSpeed: 1024000,
                    uptime: 600,
                    load1: 0.30,
                    load5: 0.20,
                    load15: 0.10,
                    tcpConnectionCount: 100,
                    udpConnectionCount: 100,
                    processCount: 100)
            ),
            isShowIP: true,
            message: "Placeholder",
            color: .blue
        )
    }
    
    func snapshot(for configuration: ServerDetailConfigurationIntent, in context: Context) async -> ServerEntry {
        let serverID = configuration.server?.serverID
        let isShowIP = configuration.isShowIP ?? false
        let color = configuration.color ?? .blue
        
        let entry = await getServerEntry(serverID: serverID, isShowIP: isShowIP, color: color)
        
        return entry
    }
    
    func timeline(for configuration: ServerDetailConfigurationIntent, in context: Context) async -> Timeline<ServerEntry> {
        let serverID = configuration.server?.serverID
        let isShowIP = configuration.isShowIP ?? false
        let color = configuration.color ?? .blue
        
        let entry = await getServerEntry(serverID: serverID, isShowIP: isShowIP, color: color)
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    func getServerEntry(serverID: Int64?, isShowIP: Bool?, color: WidgetBackgroundColor) async -> ServerEntry {
        do {
            let response = try await RequestHandler.getAllServer()
            if let server = response.data?.first(where: {
                serverID == nil || $0.id == serverID
            }) {
                return ServerEntry(
                    date: Date(),
                    server: ServerData(
                        id: server.uuid,
                        serverID: server.id,
                        name: server.name,
                        tag: "Default",
                        displayIndex: server.display_index,
                        lastActive: server.last_active,
                        ipv4: server.geoip?.ip?.ipv4_addr ?? "",
                        ipv6: server.geoip?.ip?.ipv6_addr ?? "",
                        countryCode: server.geoip?.country_code ?? "",
                        host: ServerData.Host(
                            platform: server.host.platform ?? "",
                            platformVersion: server.host.platform_version ?? "",
                            cpu: server.host.cpu ?? [""],
                            memoryTotal: server.host.mem_total ?? 0,
                            swapTotal: server.host.swap_total ?? 0,
                            diskTotal: server.host.disk_total ?? 0,
                            architecture: server.host.arch ?? "",
                            virtualization: server.host.virtualization ?? "",
                            bootTime: server.host.boot_time ?? 0
                        ),
                        status: ServerData.Status(
                            cpuUsed: server.state.cpu ?? 0,
                            memoryUsed: server.state.mem_used ?? 0,
                            swapUsed: server.state.swap_used ?? 0,
                            diskUsed: server.state.disk_used ?? 0,
                            networkIn: server.state.net_in_transfer ?? 0,
                            networkOut: server.state.net_out_speed ?? 0,
                            networkInSpeed: server.state.net_in_speed ?? 0,
                            networkOutSpeed: server.state.net_out_speed ?? 0,
                            uptime: server.state.uptime ?? 0,
                            load1: server.state.load_1 ?? 0,
                            load5: server.state.load_5 ?? 0,
                            load15: server.state.load_15 ?? 0,
                            tcpConnectionCount: server.state.tcp_conn_count ?? 0,
                            udpConnectionCount: server.state.udp_conn_count ?? 0,
                            processCount: server.state.process_count ?? 0
                        )
                    ),
                    isShowIP: isShowIP,
                    message: "OK",
                    color: color
                )
            }
            else {
                return ServerEntry(date: Date(), server: nil, isShowIP: nil, message: String(localized: "error.invalidServerConfiguration"), color: color)
            }
        }
        catch NezhaDashboardError.invalidDashboardConfiguration {
            return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.invalidDashboardConfiguration"), color: color)
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.dashboardAuthenticationFailed"), color: color)
        } catch NezhaDashboardError.invalidResponse(let message) {
            return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: message, color: color)
        } catch NezhaDashboardError.decodingError {
            return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.errorDecodingData"), color: color)
        } catch {
            return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: error.localizedDescription, color: color)
        }
    }
}

struct ServerDetailWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: ServerDetailProvider.Entry
    var color: AnyGradient {
        switch(entry.color) {
        case .blue:
            return Color.blue.gradient
        case .green:
            return Color.green.gradient
        case .orange:
            return Color.orange.gradient
        case .black:
            return Color.black.gradient
        }
    }
    
    var body: some View {
        VStack {
            if let server = entry.server {
                VStack {
                    switch(family) {
                    case .accessoryCircular:
                        let totalCore = Double(getCore(server.host.cpu) ?? 1)
                        let loadPressure = server.status.load15 / totalCore
                        
                        Gauge(value: loadPressure) {
                            Text("Load")
                        }
                    currentValueLabel: {
                        Text("\(loadPressure * 100, specifier: "%.1f")%")
                    }
                    .gaugeStyle(.accessoryCircular)
                    case .accessoryInline:
                        let cpuUsage = server.status.cpuUsed / 100
                        let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                        Text("CPU \(cpuUsage * 100, specifier: "%.0f")% MEM \(memoryUsage * 100, specifier: "%.0f")%")
                    case .accessoryRectangular:
                        let cpuUsage = server.status.cpuUsed / 100
                        let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                        VStack {
                            Text(server.name)
                                .widgetAccentable()
                            HStack {
                                HStack(spacing: 0) {
                                    Image(systemName: "cpu")
                                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                                }
                                HStack(spacing: 0) {
                                    Image(systemName: "memorychip")
                                    Text("\(memoryUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("↑ \(formatBytes(server.status.networkOut))")
                        }
                    case .systemSmall:
                        let widgetCustomizationEnabled = NMCore.userDefaults.bool(forKey: "NMWidgetCustomizationEnabled")
                        @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) var selectedWidgetBackgroundColor: Color = .blue
                        @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) var selectedWidgetTextColor: Color = .white
                        if widgetCustomizationEnabled {
                            serverDetailViewSystemSmall(server: server)
                                .foregroundStyle(selectedWidgetTextColor)
                                .containerBackground(selectedWidgetBackgroundColor, for: .widget)
                        }
                        else {
                            serverDetailViewSystemSmall(server: server)
                                .foregroundStyle(.white)
                                .containerBackground(color, for: .widget)
                        }
                    case .systemMedium:
                        let widgetCustomizationEnabled = NMCore.userDefaults.bool(forKey: "NMWidgetCustomizationEnabled")
                        @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) var selectedWidgetBackgroundColor: Color = .blue
                        @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) var selectedWidgetTextColor: Color = .white
                        if widgetCustomizationEnabled {
                            serverDetailViewSystemMedium(server: server)
                                .foregroundStyle(selectedWidgetTextColor)
                                .tint(selectedWidgetTextColor)
                                .containerBackground(selectedWidgetBackgroundColor, for: .widget)
                        }
                        else {
                            serverDetailViewSystemMedium(server: server)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .containerBackground(color, for: .widget)
                        }
                    default:
                        Text("Unsupported family")
                            .containerBackground(color, for: .widget)
                    }
                }
                .widgetURL(URL(string: "nezha://server-details?serverID=\(server.id)")!)
            }
            else {
                VStack {
                    Text(entry.message)
                    Button(intent: RefreshWidgetIntent()) {
                        Text("Retry")
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .foregroundStyle(.white)
                .containerBackground(color, for: .widget)
            }
        }
    }
    
    func serverDetailViewSystemSmall(server: ServerData) -> some View {
        Group {
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
                Text(server.name)
                    .lineLimit(1)
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.footnote)
            
            VStack(spacing: (entry.isShowIP ?? false) ? 5 : 10) {
                if let isShowIP = entry.isShowIP, isShowIP {
                    Text(server.ipv4)
                        .font(.callout)
                        .lineLimit(1)
                }
                
                let cpuUsage = server.status.cpuUsed / 100
                let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
                let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                
                HStack {
                    VStack {
                        Text("CPU")
                        Text("\(cpuUsage * 100, specifier: "%.0f")%")
                    }
                    
                    VStack {
                        Text("MEM")
                        Text("\(memoryUsage * 100, specifier: "%.0f")%")
                    }
                    
                    VStack {
                        Text("DISK")
                        Text("\(diskUsage * 100, specifier: "%.0f")%")
                    }
                }
                .font(.system(size: 14))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("↑ \(formatBytes(server.status.networkOut, decimals: 1))")
                        Text("↓ \(formatBytes(server.status.networkIn, decimals: 1))")
                    }
                }
                .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func serverDetailViewSystemMedium(server: ServerData) -> some View {
        Group {
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
                ViewThatFits {
                    HStack {
                        Text(server.name)
                        if let isShowIP = entry.isShowIP, isShowIP {
                            Text(server.ipv4)
                        }
                    }
                    .lineLimit(1)
                    Text(server.name)
                        .lineLimit(1)
                }
                .lineLimit(1)
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    HStack(spacing: 5) {
                        HStack {
                            Image(systemName: "power")
                                .frame(width: 10)
                            Text("\(formatTimeInterval(seconds: server.status.uptime))")
                        }
                        .font(.caption)
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.subheadline)
            
            ViewThatFits {
                HStack(spacing: 20) {
                    gaugeView(server: server)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("↑ \(formatBytes(server.status.networkOut, decimals: 1))")
                            Text("↓ \(formatBytes(server.status.networkIn, decimals: 1))")
                        }
                    }
                    .font(.system(size: 14))
                }
                
                gaugeView(server: server)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func gaugeView(server: ServerData) -> some View {
        HStack(spacing: 10) {
            let cpuUsage = server.status.cpuUsed / 100
            let memoryUsage = (server.host.memoryTotal == 0 ? 0 : Double(server.status.memoryUsed) / Double(server.host.memoryTotal))
            let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
            
            Gauge(value: cpuUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("CPU")
                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                }
            }
            
            Gauge(value: memoryUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("MEM")
                    Text("\(memoryUsage * 100, specifier: "%.0f")%")
                }
            }
            
            Gauge(value: diskUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("DISK")
                    Text("\(diskUsage * 100, specifier: "%.0f")%")
                }
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

struct ServerEntry: TimelineEntry {
    let date: Date
    let server: ServerData?
    let isShowIP: Bool?
    let message: String
    let color: WidgetBackgroundColor
}

struct ServerDetailWidget: Widget {
    let kind: String = "ServerDetailWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerDetailConfigurationIntent.self, provider: ServerDetailProvider()) { entry in
            ServerDetailWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Server Details")
        .description("View details of your server at a glance.")
#if os(iOS)
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
#endif
#if os(macOS)
        .supportedFamilies([.systemSmall, .systemMedium])
#endif
    }
}

//#Preview("ServerDetailWidget", as: .systemMedium) {
//    ServerDetailWidget()
//} timeline: {
//    ServerEntry(date: Date(), server: Server(id: 0, name: "Demo", tag: "Group", lastActive: 0, IPv4: "255.255.255.255", IPv6: "::1", validIP: "255.255.255.255", displayIndex: 0, host: ServerHost(platform: "debian", platformVersion: "12", cpu: ["Intel 4 Virtual Core"], gpu: nil, memTotal: 1024000, diskTotal: 1024000, swapTotal: 1024000, arch: "x86_64", virtualization: "kvm", bootTime: 0, countryCode: "us", version: "1"), status: ServerStatus(cpu: 100, memUsed: 1024000, swapUsed: 1024000, diskUsed: 1024000, netInTransfer: 1024000, netOutTransfer: 1024000, netInSpeed: 1024000, netOutSpeed: 1024000, uptime: 600, load1: 0.30, load5: 0.20, load15: 0.10, TCPConnectionCount: 100, UDPConnectionCount: 100, processCount: 100)), isShowIP: true, message: "OK", color: .blue)
//}
