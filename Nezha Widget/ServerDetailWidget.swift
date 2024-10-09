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
        ServerEntry(date: Date(), server: Server(id: 0, name: "Demo", tag: "Group", lastActive: 0, IPv4: "255.255.255.255", IPv6: "::1", validIP: "255.255.255.255", displayIndex: 0, host: ServerHost(platform: "debian", platformVersion: "12", cpu: ["Intel 4 Virtual Core"], gpu: nil, memTotal: 1024000, diskTotal: 1024000, swapTotal: 1024000, arch: "x86_64", virtualization: "kvm", bootTime: 0, countryCode: "us", version: "1"), status: ServerStatus(cpu: 100, memUsed: 1024000, swapUsed: 1024000, diskUsed: 1024000, netInTransfer: 1024000, netOutTransfer: 1024000, netInSpeed: 1024000, netOutSpeed: 1024000, uptime: 600, load1: 0.30, load5: 0.20, load15: 0.10, TCPConnectionCount: 100, UDPConnectionCount: 100, processCount: 100)), isShowIP: true, message: "Placeholder", color: .blue)
    }
    
    func snapshot(for configuration: ServerDetailConfigurationIntent, in context: Context) async -> ServerEntry {
        let serverID: Int? = configuration.server?.id
        let isShowIP: Bool = configuration.isShowIP ?? false
        let color: WidgetBackgroundColor = configuration.color ?? .blue
        do {
            if let serverID {
                let response = try await RequestHandler.getServerDetail(serverID: String(serverID))
                if let server = response.result?.first {
                    return ServerEntry(date: Date(), server: server, isShowIP: isShowIP, message: "OK", color: color)
                }
                else {
                    return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.invalidServerConfiguration"), color: color)
                }
            }
            else {
                let response = try await RequestHandler.getAllServerDetail()
                if let server = response.result?.first {
                    return ServerEntry(date: Date(), server: server, isShowIP: configuration.isShowIP, message: "OK", color: color)
                }
                else {
                    return ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.invalidServerConfiguration"), color: color)
                }
            }
        } catch NezhaDashboardError.invalidDashboardConfiguration {
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
    
    func timeline(for configuration: ServerDetailConfigurationIntent, in context: Context) async -> Timeline<ServerEntry> {
        let serverID: Int? = configuration.server?.id
        let isShowIP: Bool = configuration.isShowIP ?? false
        let color: WidgetBackgroundColor = configuration.color ?? .blue
        do {
            if let serverID {
                let response = try await RequestHandler.getServerDetail(serverID: String(serverID))
                if let server = response.result?.first {
                    let entries = [ServerEntry(date: Date(), server: server, isShowIP: isShowIP, message: "OK", color: color)]
                    return Timeline(entries: entries, policy: .atEnd)
                }
                else {
                    let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.invalidServerConfiguration"), color: color)]
                    return Timeline(entries: entries, policy: .atEnd)
                }
            }
            else {
                let response = try await RequestHandler.getAllServerDetail()
                if let server = response.result?.first {
                    let entries = [ServerEntry(date: Date(), server: server, isShowIP: configuration.isShowIP, message: "OK", color: color)]
                    return Timeline(entries: entries, policy: .atEnd)
                }
                else {
                    let entries = [ServerEntry(date: Date(), server: nil, isShowIP: nil, message: String(localized: "error.invalidServerConfiguration"), color: color)]
                    return Timeline(entries: entries, policy: .atEnd)
                }
            }
        } catch NezhaDashboardError.invalidDashboardConfiguration {
            let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.invalidDashboardConfiguration"), color: color)]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.dashboardAuthenticationFailed"), color: color)]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.invalidResponse(let message) {
            let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: message, color: color)]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.decodingError {
            let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: String(localized: "error.errorDecodingData"), color: color)]
            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            let entries = [ServerEntry(date: Date(), server: nil, isShowIP: isShowIP, message: error.localizedDescription, color: color)]
            return Timeline(entries: entries, policy: .atEnd)
        }
    }
    
    func recommendations() -> [AppIntentRecommendation<ServerDetailConfigurationIntent>] {
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
        let lastViewedServerID = userDefaults.integer(forKey: "NMLastViewedServerID")
        return [AppIntentRecommendation(intent: ServerDetailConfigurationIntent(server: ServerEntity(id: lastViewedServerID, name: "Last Viewed", displayIndex: nil), isShowIP: false, color: .blue), description: "Last viewed server")]
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
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        Text("CPU \(cpuUsage * 100, specifier: "%.0f")% MEM \(memUsage * 100, specifier: "%.0f")%")
                    case .accessoryRectangular:
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
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
                                    Text("\(memUsage * 100, specifier: "%.0f")%")
                                }
                            }
                            Text("↑\(formatBytes(server.status.netOutTransfer))")
                        }
                    case .systemSmall:
                        let widgetCustomizationEnabled = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.bool(forKey: "NMWidgetCustomizationEnabled")
                        @AppStorage("NMWidgetBackgroundColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var selectedWidgetBackgroundColor: Color = .blue
                        @AppStorage("NMWidgetTextColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var selectedWidgetTextColor: Color = .white
                        if let widgetCustomizationEnabled, widgetCustomizationEnabled {
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
                        let widgetCustomizationEnabled = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.bool(forKey: "NMWidgetCustomizationEnabled")
                        @AppStorage("NMWidgetBackgroundColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var selectedWidgetBackgroundColor: Color = .blue
                        @AppStorage("NMWidgetTextColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var selectedWidgetTextColor: Color = .white
                        if let widgetCustomizationEnabled, widgetCustomizationEnabled {
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
            }
        }
    }
    
    func serverDetailViewSystemSmall(server: Server) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(countryFlagEmoji(countryCode: server.host.countryCode))
                Text(server.name)
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.footnote)
            
            VStack(spacing: (entry.isShowIP ?? false) ? 5 : 10) {
                if let isShowIP = entry.isShowIP, isShowIP {
                    Text(server.IPv4)
                        .font(.callout)
                }
                
                HStack {
                    let cpuUsage = server.status.cpu / 100
                    let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                    let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                    
                    VStack {
                        Text("CPU")
                        Text("\(cpuUsage * 100, specifier: "%.0f")%")
                    }
                    
                    VStack {
                        Text("MEM")
                        Text("\(memUsage * 100, specifier: "%.0f")%")
                    }
                    
                    VStack {
                        Text("DISK")
                        Text("\(diskUsage * 100, specifier: "%.0f")%")
                    }
                }
                .font(.caption)
                
                HStack {
                    HStack {
                        Image(systemName: "power")
                        Text("\(formatTimeInterval(seconds: server.status.uptime, shortened: true))")
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("↑\(formatBytes(server.status.netOutTransfer))")
                            Text("↓\(formatBytes(server.status.netInTransfer))")
                        }
                    }
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func serverDetailViewSystemMedium(server: Server) -> some View {
        VStack(spacing: 0) {
            HStack {
                if server.host.countryCode.uppercased() == "TW" {
                    Image("TWFlag")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                }
                else if server.host.countryCode.uppercased() != "" {
                    Text(countryFlagEmoji(countryCode: server.host.countryCode))
                        .frame(width: 20)
                }
                ViewThatFits {
                    HStack {
                        Text(server.name)
                        if let isShowIP = entry.isShowIP, isShowIP {
                            Text(server.IPv4)
                        }
                    }
                    Text(server.name)
                }
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    HStack(spacing: 5) {
                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.subheadline)
            
            HStack {
                VStack(spacing: 0) {
                    gaugeView(server: server)
                }
                Spacer()
                ViewThatFits {
                    VStack(spacing: 10) {
                        infoViewUpperSection(server: server)
                        infoViewLowerSection(server: server)
                    }
                    infoViewUpperSection(server: server)
                }
                .font(.caption2)
                .frame(maxWidth: 100)
                .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func gaugeView(server: Server) -> some View {
        HStack {
            let cpuUsage = server.status.cpu / 100
            let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
            let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
            
            Gauge(value: cpuUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("CPU")
                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                }
            }
            
            Gauge(value: memUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("MEM")
                    Text("\(memUsage * 100, specifier: "%.0f")%")
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
    
    func infoViewUpperSection(server: Server) -> some View {
        VStack(alignment: .leading) {
            if let core = getCore(server.host.cpu) {
                HStack {
                    Image(systemName: "cpu")
                        .frame(width: 10)
                    Text("\(core) Core")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Image(systemName: "memorychip")
                    .frame(width: 10)
                Text("\(formatBytes(server.host.memTotal))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "internaldrive")
                    .frame(width: 10)
                Text("\(formatBytes(server.host.diskTotal))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func infoViewLowerSection(server: Server) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "power")
                    .frame(width: 10)
                Text("\(formatTimeInterval(seconds: server.status.uptime))")
            }
            
            HStack {
                Image(systemName: "circle.dotted.circle")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑\(formatBytes(server.status.netOutTransfer))")
                    Text("↓\(formatBytes(server.status.netInTransfer))")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ServerEntry: TimelineEntry {
    let date: Date
    let server: Server?
    let isShowIP: Bool?
    let message: String
    let color: WidgetBackgroundColor
}

struct ServerDetailWidget: Widget {
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMLastModifyDate": 0,
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMLastViewedServerID": 0
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
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
