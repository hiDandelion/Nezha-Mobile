//
//  ServerCountWidget.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/28/25.
//

import WidgetKit
import SwiftUI

struct ServerCountProvider: AppIntentTimelineProvider {
    typealias Entry = ServerCountEntry
    
    typealias Intent = ServerCountConfigurationIntent
    
    func placeholder(in context: Context) -> ServerCountEntry {
        ServerCountEntry(date: Date(), onlineCount: 47, offlineCount: 5, isHideOffline: true, message: "Placeholder", color: .blue)
    }
    
    func snapshot(for configuration: ServerCountConfigurationIntent, in context: Context) async -> ServerCountEntry {
        let isHideOffline = configuration.isHideOffline ?? false
        let color = configuration.color ?? .blue
        
        let entry = await getServerCountEntry(isHideOffline: isHideOffline, color: color)
        
        return entry
    }
    
    func timeline(for configuration: ServerCountConfigurationIntent, in context: Context) async -> Timeline<ServerCountEntry> {
        let isHideOffline = configuration.isHideOffline ?? false
        let color = configuration.color ?? .blue
        
        let entry = await getServerCountEntry(isHideOffline: isHideOffline, color: color)
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    func getServerCountEntry(isHideOffline: Bool?, color: WidgetBackgroundColor) async -> ServerCountEntry {
        do {
            let response = try await RequestHandler.getServer()
            if let data = response.data {
                let onlineCount = data.filter({ isServerOnline(timestamp: $0.last_active) }).count
                let offlineCount = data.count - onlineCount
                return ServerCountEntry(date: Date(), onlineCount: onlineCount, offlineCount: offlineCount, isHideOffline: isHideOffline, message: "OK", color: color)
            }
            else {
                return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: "No Server Data", color: color)
            }
        }
        catch NezhaDashboardError.invalidDashboardConfiguration {
            return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: String(localized: "error.invalidDashboardConfiguration"), color: color)
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: String(localized: "error.dashboardAuthenticationFailed"), color: color)
        } catch NezhaDashboardError.invalidResponse(let message) {
            return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: message, color: color)
        } catch NezhaDashboardError.decodingError {
            return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: String(localized: "error.errorDecodingData"), color: color)
        } catch {
            return ServerCountEntry(date: Date(), onlineCount: nil, offlineCount: nil, isHideOffline: isHideOffline, message: error.localizedDescription, color: color)
        }
    }
}

struct ServerCountWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) var selectedWidgetBackgroundColor: Color = .blue
    @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) var selectedWidgetTextColor: Color = .white
    var entry: ServerCountProvider.Entry
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
        Group {
            if let onlineCount = entry.onlineCount, let offlineCount = entry.offlineCount {
                Group {
                    switch(family) {
                    case .systemSmall:
                        serverCountViewSystemSmall(onlineCount: onlineCount, offlineCount: offlineCount, isHideOffline: entry.isHideOffline)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .containerBackground(color, for: .widget)
                    case .systemMedium:
                        EmptyView()
                    default:
                        Text("Unsupported family")
                            .containerBackground(color, for: .widget)
                    }
                }
            }
        }
    }
    
    func serverCountViewSystemSmall(onlineCount: Int, offlineCount: Int, isHideOffline: Bool?) -> some View {
        VStack {
            HStack {
                Text("Server Count")
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.footnote)
            Spacer()
            if isHideOffline == true {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("\(onlineCount)")
                        .font(.system(size: 36, design: .rounded))
                }
                .minimumScaleFactor(0.1)
                .lineLimit(1)
            }
            else {
                HStack {
                    Spacer()
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text("\(onlineCount)")
                            .font(.system(size: 36, design: .rounded))
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                        Text("\(offlineCount)")
                            .font(.system(size: 20, design: .rounded))
                    }
                    Spacer()
                }
                .minimumScaleFactor(0.1)
                .lineLimit(1)
            }
            Spacer()
        }
    }
}

struct ServerCountEntry: TimelineEntry {
    let date: Date
    let onlineCount: Int?
    let offlineCount: Int?
    let isHideOffline: Bool?
    let message: String
    let color: WidgetBackgroundColor
}

struct ServerCountWidget: Widget {
    let kind: String = "ServerCountWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerCountConfigurationIntent.self, provider: ServerCountProvider()) { entry in
            ServerCountWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Server Count")
        .description("Count your servers with minimal effort.")
        .supportedFamilies([.systemSmall])
    }
}
