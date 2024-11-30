//
//  AgentWidget.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

#if os(iOS)
import WidgetKit
import SwiftUI

struct AgentProvider: AppIntentTimelineProvider {
    typealias Entry = AgentEntry
    
    typealias Intent = AgentConfigurationContent
    
    func placeholder(in context: Context) -> AgentEntry {
        let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
        let OSVersionNumber = DeviceInfo.getOSVersionNumber()
        let cpuUsage = DeviceInfo.getCPUUsage()
        let memoryUsed = DeviceInfo.getMemoryUsed()
        let memoryTotal = DeviceInfo.getMemoryTotal()
        let diskUsed = DeviceInfo.getDiskUsed()
        let diskTotal = DeviceInfo.getDiskTotal()
        let uptime = DeviceInfo.getUptime()
        
        return AgentEntry(date: Date(), deviceModelIdentifier: deviceModelIdentifier, OSVersionNumber: OSVersionNumber, cpuUsage: cpuUsage, memoryUsed: memoryUsed, memoryTotal: memoryTotal, diskUsed: diskUsed, diskTotal: diskTotal, uptime: uptime, color: .blue)
    }
    
    func snapshot(for configuration: AgentConfigurationContent, in context: Context) async -> AgentEntry {
        let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
        let OSVersionNumber = DeviceInfo.getOSVersionNumber()
        let cpuUsage = DeviceInfo.getCPUUsage()
        let memoryUsed = DeviceInfo.getMemoryUsed()
        let memoryTotal = DeviceInfo.getMemoryTotal()
        let diskUsed = DeviceInfo.getDiskUsed()
        let diskTotal = DeviceInfo.getDiskTotal()
        let bootTime = DeviceInfo.getBootTime()
        let uptime = DeviceInfo.getUptime()
        
        let color: WidgetBackgroundColor = configuration.color ?? .blue
        
        if configuration.report == true {
            _ = try? await RequestHandler.reportDeviceInfo(identifier: deviceModelIdentifier, systemVersion: OSVersionNumber, memoryTotal: memoryTotal, diskTotal: diskTotal, bootTime: bootTime, agentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown", cpuUsage: cpuUsage, memoryUsed: memoryUsed, diskUsed: diskUsed, uptime: uptime, networkIn: 0, networkOut: 0, networkInSpeed: 0, networkOutSpeed: 0)
        }
        
        return AgentEntry(date: Date(), deviceModelIdentifier: deviceModelIdentifier, OSVersionNumber: OSVersionNumber, cpuUsage: cpuUsage, memoryUsed: memoryUsed, memoryTotal: memoryTotal, diskUsed: diskUsed, diskTotal: diskTotal, uptime: uptime, color: color)
    }
    
    func timeline(for configuration: AgentConfigurationContent, in context: Context) async -> Timeline<AgentEntry> {
        let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
        let OSVersionNumber = DeviceInfo.getOSVersionNumber()
        let cpuUsage = DeviceInfo.getCPUUsage()
        let memoryUsed = DeviceInfo.getMemoryUsed()
        let memoryTotal = DeviceInfo.getMemoryTotal()
        let diskUsed = DeviceInfo.getDiskUsed()
        let diskTotal = DeviceInfo.getDiskTotal()
        let bootTime = DeviceInfo.getBootTime()
        let uptime = DeviceInfo.getUptime()
        
        let color: WidgetBackgroundColor = configuration.color ?? .blue
        
        if configuration.report == true {
            _ = try? await RequestHandler.reportDeviceInfo(identifier: deviceModelIdentifier, systemVersion: OSVersionNumber, memoryTotal: memoryTotal, diskTotal: diskTotal, bootTime: bootTime, agentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown", cpuUsage: cpuUsage, memoryUsed: memoryUsed, diskUsed: diskUsed, uptime: uptime, networkIn: 0, networkOut: 0, networkInSpeed: 0, networkOutSpeed: 0)
        }
        
        return Timeline(entries: [AgentEntry(date: Date(), deviceModelIdentifier: deviceModelIdentifier, OSVersionNumber: OSVersionNumber, cpuUsage: cpuUsage, memoryUsed: memoryUsed, memoryTotal: memoryTotal, diskUsed: diskUsed, diskTotal: diskTotal, uptime: uptime, color: color)], policy: .atEnd)
    }
    
    func recommendations() -> [AppIntentRecommendation<AgentConfigurationContent>] {
        return [AppIntentRecommendation(intent: AgentConfigurationContent(report: false, color: .blue), description: "Agent")]
    }
}

struct AgentWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: AgentProvider.Entry
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
            switch(family) {
            case .systemSmall:
                let widgetCustomizationEnabled = NMCore.userDefaults.bool(forKey: "NMWidgetCustomizationEnabled")
                @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) var selectedWidgetBackgroundColor: Color = .blue
                @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) var selectedWidgetTextColor: Color = .white
                if widgetCustomizationEnabled {
                    agentViewSystemSmall
                        .foregroundStyle(selectedWidgetTextColor)
                        .containerBackground(selectedWidgetBackgroundColor, for: .widget)
                }
                else {
                    agentViewSystemSmall
                        .foregroundStyle(.white)
                        .containerBackground(color, for: .widget)
                }
                
            case .systemMedium:
                let widgetCustomizationEnabled = NMCore.userDefaults.bool(forKey: "NMWidgetCustomizationEnabled")
                @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) var selectedWidgetBackgroundColor: Color = .blue
                @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) var selectedWidgetTextColor: Color = .white
                if widgetCustomizationEnabled {
                    agentViewSystemSmall
                        .foregroundStyle(selectedWidgetTextColor)
                        .tint(selectedWidgetTextColor)
                        .containerBackground(selectedWidgetBackgroundColor, for: .widget)
                }
                else {
                    agentViewSystemMedium
                        .foregroundStyle(.white)
                        .tint(.white)
                        .containerBackground(color, for: .widget)
                }
                
            default:
                Text("Unsupported family")
            }
        }
    }
    
    var agentViewSystemSmall: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent")
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.footnote)
            
            VStack(spacing: 10) {
                HStack {
                    let cpuUsage = entry.cpuUsage / 100
                    let memoryUsage = Double(entry.memoryUsed) / Double(entry.memoryTotal)
                    let diskUsage = Double(entry.diskUsed) / Double(entry.diskTotal)
                    
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
                .font(.caption)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "iphone")
                            .frame(width: 10)
                        Text(entry.deviceModelIdentifier)
                    }
                    
                    HStack {
                        Image(systemName: "power")
                            .frame(width: 10)
                        Text("\(formatTimeInterval(seconds: entry.uptime))")
                    }
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var agentViewSystemMedium: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Nezha Agent")
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
                gaugeView(cpuUsage: entry.cpuUsage, memoryUsed: entry.memoryUsed, memoryTotal: entry.memoryTotal, diskUsed: entry.diskUsed, diskTotal: entry.diskTotal)
                infoView(deviceModelIdentifier: entry.deviceModelIdentifier, memoryTotal: entry.memoryTotal, diskTotal: entry.diskTotal, uptime: entry.uptime)
                    .font(.caption2)
                    .frame(maxWidth: 100)
                    .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func gaugeView(cpuUsage: Double, memoryUsed: Int64, memoryTotal: Int64, diskUsed: Int64, diskTotal: Int64) -> some View {
        HStack {
            let cpuUsage = cpuUsage / 100
            let memoryUsage = Double(memoryUsed) / Double(memoryTotal)
            let diskUsage = Double(diskUsed) / Double(diskTotal)
            
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
    
    func infoView(deviceModelIdentifier: String, memoryTotal: Int64, diskTotal: Int64, uptime: Int64) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "iphone")
                    .frame(width: 10)
                Text(deviceModelIdentifier)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "memorychip")
                    .frame(width: 10)
                Text("\(formatBytes(memoryTotal))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "internaldrive")
                    .frame(width: 10)
                Text("\(formatBytes(diskTotal))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "power")
                    .frame(width: 10)
                Text("\(formatTimeInterval(seconds: uptime))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AgentEntry: TimelineEntry {
    let date: Date
    let deviceModelIdentifier: String
    let OSVersionNumber: String
    let cpuUsage: Double
    let memoryUsed: Int64
    let memoryTotal: Int64
    let diskUsed: Int64
    let diskTotal: Int64
    let uptime: Int64
    let color: WidgetBackgroundColor
}

struct AgentWidget: Widget {
    let kind: String = "AgentWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: AgentConfigurationContent.self, provider: AgentProvider()) { entry in
            AgentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Agent")
        .description("View and report your device information.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

//#Preview("AgentWidget", as: .systemMedium) {
//    AgentWidget()
//} timeline: {
//    let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
//    let OSVersionNumber = DeviceInfo.getOSVersionNumber()
//    let cpuUsage = DeviceInfo.getCPUUsage()
//    let memoryTotal = DeviceInfo.getMemoryTotal()
//    let memoryUsed = DeviceInfo.getMemoryUsed()
//    let diskUsed = DeviceInfo.getDiskUsed()
//    let diskTotal = DeviceInfo.getDiskTotal()
//    let bootTime = DeviceInfo.getBootTime()
//    let uptime = DeviceInfo.getUptime()
//    AgentEntry(date: Date(), deviceModelIdentifier: deviceModelIdentifier, OSVersionNumber: OSVersionNumber, cpuUsage: cpuUsage, memoryUsed: memoryUsed, memoryTotal: memoryTotal, diskUsed: diskUsed, diskTotal: diskTotal, uptime: uptime)
//}
#endif
