//
//  NezhaWatchWidget.swift
//  Nezha Watch Widget
//
//  Created by Junhui Lou on 8/26/24.
//

import WidgetKit
import SwiftUI

struct ServerDetailProvider: AppIntentTimelineProvider {
    typealias Entry = ServerEntry
    
    typealias Intent = SpecifyServerIntent
    
    func placeholder(in context: Context) -> ServerEntry {
        ServerEntry(date: Date(), server: GetServerDetailResponse.Server(id: 0, name: "Demo", tag: "Group", lastActive: 0, IPv4: "255.255.255.255", IPv6: "::1", validIP: "255.255.255.255", displayIndex: 0, host: GetServerDetailResponse.ServerHost(platform: "debian", platformVersion: "12", cpu: ["Intel 4 Virtual Core"], gpu: nil, memTotal: 1024000, diskTotal: 1024000, swapTotal: 1024000, arch: "x86_64", virtualization: "kvm", bootTime: 0, countryCode: "us", version: "1"), status: GetServerDetailResponse.ServerStatus(cpu: 100, memUsed: 1024000, swapUsed: 1024000, diskUsed: 1024000, netInTransfer: 1024000, netOutTransfer: 1024000, netInSpeed: 1024000, netOutSpeed: 1024000, uptime: 600, load1: 0.30, load5: 0.20, load15: 0.10, TCPConnectionCount: 100, UDPConnectionCount: 100, processCount: 100)), message: "Placeholder")
    }
    
    func snapshot(for configuration: SpecifyServerIntent, in context: Context) async -> ServerEntry {
        let userDefaults = NMCore.userDefaults
        let serverID: Int? = userDefaults.integer(forKey: "NMWatchLastViewedServerID")
        do {
            if let serverID {
                let response = try await RequestHandler.getServerDetail(serverID: String(serverID))
                if let server = response.result?.first {
                    return ServerEntry(date: Date(), server: server, message: "OK")
                }
                else {
                    return ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidServerConfiguration"))
                }
            }
            else {
                let response = try await RequestHandler.getAllServerDetail()
                if let server = response.result?.first {
                    return ServerEntry(date: Date(), server: server, message: "OK")
                }
                else {
                    return ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidServerConfiguration"))
                }
            }
        } catch NezhaDashboardError.invalidDashboardConfiguration {
            return ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidDashboardConfiguration"))
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            return ServerEntry(date: Date(), server: nil, message: String(localized: "error.dashboardAuthenticationFailed"))
        } catch NezhaDashboardError.invalidResponse(let message) {
            return ServerEntry(date: Date(), server: nil, message: message)
        } catch NezhaDashboardError.decodingError {
            return ServerEntry(date: Date(), server: nil, message: String(localized: "error.errorDecodingData"))
        } catch {
            return ServerEntry(date: Date(), server: nil, message: error.localizedDescription)
        }
    }
    
    func timeline(for configuration: SpecifyServerIntent, in context: Context) async -> Timeline<ServerEntry> {
        let userDefaults = NMCore.userDefaults
        let serverID: Int? = userDefaults.integer(forKey: "NMWatchLastViewedServerID")
        do {
            if let serverID {
                let response = try await RequestHandler.getServerDetail(serverID: String(serverID))
                if let server = response.result?.first {
                    let entries = [ServerEntry(date: Date(), server: server, message: "OK")]
                    return Timeline(entries: entries, policy: .atEnd)
                }
                else {
                    let entries = [ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidServerConfiguration"))]
                    return Timeline(entries: entries, policy: .atEnd)
                }
            }
            else {
                let response = try await RequestHandler.getAllServerDetail()
                if let server = response.result?.first {
                    let entries = [ServerEntry(date: Date(), server: server, message: "OK")]
                    return Timeline(entries: entries, policy: .atEnd)
                }
                else {
                    let entries = [ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidServerConfiguration"))]
                    return Timeline(entries: entries, policy: .atEnd)
                }
            }
        } catch NezhaDashboardError.invalidDashboardConfiguration {
            let entries = [ServerEntry(date: Date(), server: nil, message: String(localized: "error.invalidDashboardConfiguration"))]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            let entries = [ServerEntry(date: Date(), server: nil, message: String(localized: "error.dashboardAuthenticationFailed"))]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.invalidResponse(let message) {
            let entries = [ServerEntry(date: Date(), server: nil, message: message)]
            return Timeline(entries: entries, policy: .atEnd)
        } catch NezhaDashboardError.decodingError {
            let entries = [ServerEntry(date: Date(), server: nil, message: String(localized: "error.errorDecodingData"))]
            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            let entries = [ServerEntry(date: Date(), server: nil, message: error.localizedDescription)]
            return Timeline(entries: entries, policy: .atEnd)
        }
    }
    
    func recommendations() -> [AppIntentRecommendation<SpecifyServerIntent>] {
        let lastViewedServerID = NMCore.userDefaults.integer(forKey: "NMWatchLastViewedServerID")
        return [AppIntentRecommendation(intent: SpecifyServerIntent(server: ServerEntity(id: lastViewedServerID, name: "Last Viewed", displayIndex: nil)), description: "Last viewed server")]
    }
}

struct ServerEntry: TimelineEntry {
    let date: Date
    let server: GetServerDetailResponse.Server?
    let message: String
}

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: ServerDetailProvider.Entry
    
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
                        } currentValueLabel: {
                            Text("\(loadPressure * 100, specifier: "%.0f")%")
                        }
                        .gaugeStyle(.accessoryCircular)
                    case .accessoryCorner:
                        let totalCore = Double(getCore(server.host.cpu) ?? 1)
                        let loadPressure = server.status.load15 / totalCore
                        let gradient = Gradient(colors: [.green, .pink])
                        Text("\(loadPressure * 100, specifier: "%.0f")%")
                            .widgetCurvesContent()
                            .widgetLabel {
                                ProgressView(value: loadPressure)
                                    .tint(gradient)
                            }
                    case .accessoryRectangular:
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        VStack {
                            HStack {
                                Text(server.name)
                                    .widgetAccentable()
                                Spacer()
                                Text(entry.date.formatted(date: .omitted, time: .shortened))
                            }
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
                            ViewThatFits(in: .horizontal) {
                                HStack {
                                    Text("↓ \(formatBytes(server.status.netInTransfer))")
                                    Text("↑ \(formatBytes(server.status.netOutTransfer))")
                                }
                                Text("↑ \(formatBytes(server.status.netOutTransfer))")
                            }
                        }
                    case .accessoryInline:
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        Text("CPU \(cpuUsage * 100, specifier: "%.0f")% MEM \(memUsage * 100, specifier: "%.0f")%")
                    default:
                        Text("Unsupported family")
                    }
                }
                .widgetURL(URL(string: "nezha://server-details?serverID=\(server.id)")!)
            }
            else {
                VStack {
                    switch(family) {
                    case .accessoryCircular:
                        Gauge(value: 0) {
                            Text("Load")
                        }
                    currentValueLabel: {
                        Text("--%")
                    }
                    .gaugeStyle(.accessoryCircular)
                    case .accessoryCorner:
                        let gradient = Gradient(colors: [.green, .pink])
                        Text("--%")
                            .widgetCurvesContent()
                            .widgetLabel {
                                ProgressView(value: 0)
                                    .tint(gradient)
                            }
                    case .accessoryRectangular:
                        Text("An error occurred")
                    case .accessoryInline:
                        Text("CPU --% MEM --%")
                    default:
                        Text("Unsupported family")
                    }
                }
            }
        }
        .containerBackground(.blue.gradient, for: .widget)
    }
}

@main
struct NezhaWatchWidgetApp: Widget {
    init() {
        NMCore.registerUserDefaults()
    }
    
    let kind: String = "ServerDetailWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SpecifyServerIntent.self, provider: ServerDetailProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Server Details")
        .description("View details of your server at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

//struct NezhaWatchWidgetApp_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetEntryView(entry: ServerEntry(date: Date(), server: Server(id: 0, name: "Demo", tag: "Group", lastActive: 0, IPv4: "255.255.255.255", IPv6: "::1", validIP: "255.255.255.255", displayIndex: 0, host: ServerHost(platform: "debian", platformVersion: "12", cpu: ["Intel 4 Virtual Core"], gpu: nil, memTotal: 1024000, diskTotal: 1024000, swapTotal: 1024000, arch: "x86_64", virtualization: "kvm", bootTime: 0, countryCode: "us", version: "1"), status: ServerStatus(cpu: 100, memUsed: 1024000, swapUsed: 1024000, diskUsed: 1024000, netInTransfer: 1024000, netOutTransfer: 1024000, netInSpeed: 1024000, netOutSpeed: 1024000, uptime: 600, load1: 0.30, load5: 0.20, load15: 0.10, TCPConnectionCount: 100, UDPConnectionCount: 100, processCount: 100)), message: "OK"))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//        WidgetEntryView(entry: ServerEntry(date: Date(), server: nil, message: "Error Description"))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//    }
//}
