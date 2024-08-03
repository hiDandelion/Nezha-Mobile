//
//  WidgetApp.swift
//  WidgetApp
//
//  Created by Junhui Lou on 8/2/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ServerEntry {
        ServerEntry(date: Date(), server: Server(id: 0, name: "Demo", ipv4: "1.1.1.1", ipv6: "1::", host: ServerHost(cpu: ["1 Virtual Core"], memTotal: 1024, diskTotal: 1024, countryCode: "US"), status: ServerStatus(cpu: 0.10, memUsed: 1024, diskUsed: 1024, netInTransfer: 1024, netOutTransfer: 1024, uptime: 60, load15: 0.10)), message: "Placeholder")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ServerEntry) -> ()) {
        fetchServerData(completion: { response, errorDescription in
            if let response {
                completion(ServerEntry(date: Date(), server: response.result![0], message: "OK"))
            }
            if let errorDescription {
                completion(ServerEntry(date: Date(), server: nil, message: errorDescription))
            }
        })
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchServerData(completion: { response, errorDescription in
            if let response {
                let entries = [ServerEntry(date: Date(), server: response.result![0], message: "OK")]
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
            if let errorDescription {
                let entries = [ServerEntry(date: Date(), server: nil, message: errorDescription)]
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        })
    }
    
    func fetchServerData(completion: @escaping (_ response: HTTPResponse?, _ errorDescription: String?) -> Void) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let widgetDashboardLink = userDefaults.string(forKey: "widgetDashboardLink"),
              let widgetAPIToken = userDefaults.string(forKey: "widgetAPIToken"),
              let widgetServerID = userDefaults.string(forKey: "widgetServerID"),
              let url = URL(string: "https://\(widgetDashboardLink)/api/v1/server/details?id=\(widgetServerID)") else {
            print("Error obtaining connection info")
            completion(nil, String(localized: "error.invalidConfiguration"))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(widgetAPIToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, String(localized: "error.errorReceivingData"))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let httpResponse = try decoder.decode(HTTPResponse.self, from: data)
                
                if httpResponse.result != nil {
                    completion(httpResponse, nil)
                    return
                }
                
                if httpResponse.code == 403 {
                    completion(nil, String(localized: "error.authenticationFailed"))
                    return
                }
                
                completion(nil, httpResponse.message)
                return
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                completion(nil, String(localized: "error.errorDecodingData"))
            }
        }
        .resume()
    }
}

struct ServerEntry: TimelineEntry {
    let date: Date
    let server: Server?
    let message: String
}

struct WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let server = entry.server {
            switch(family) {
            case .systemSmall:
                VStack(spacing: 0) {
                    HStack {
                        Text(countryFlagEmoji(countryCode: server.host.countryCode))
                        Text(server.name)
                        Spacer()
                        Button(intent: RefreshServerIntent()) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.footnote)
                    
                    VStack(spacing: 5) {
                        Text(server.ipv4)
                        
                        HStack {
                            let cpuUsage = server.status.cpu / 100
                            let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                            let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                            
                            VStack {
                                Text("CPU")
                                Text("\(cpuUsage * 100, specifier: "%.0f")%")
                            }
                            
                            VStack {
                                Text("Memory")
                                Text("\(memUsage * 100, specifier: "%.0f")%")
                            }
                            
                            VStack {
                                Text("Disk")
                                Text("\(diskUsage * 100, specifier: "%.0f")%")
                            }
                        }
                        .font(.caption)
                        
                        HStack {
                            HStack {
                                Image(systemName: "power")
                                Text("\(formatTimeInterval(seconds: server.status.uptime))")
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
                .foregroundStyle(.white)
            case .systemMedium:
                VStack(spacing: 0) {
                    HStack {
                        Text(countryFlagEmoji(countryCode: server.host.countryCode))
                        Text(server.name)
                        Text(server.ipv4)
                        Spacer()
                        Button(intent: RefreshServerIntent()) {
                            Text(entry.date.formatted(date: .omitted, time: .shortened))
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.subheadline)
                    
                    HStack {
                        VStack(spacing: 0) {
                            gaugeView(server: server)
                        }
                        Spacer()
                        infoView(server: server)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .foregroundStyle(.white)
            default:
                Text("Unsupported family")
                    .foregroundStyle(.white)
            }
        }
        else {
            Text(entry.message)
                .foregroundStyle(.white)
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
        .tint(.cyan)
    }
    
    func infoView(server: Server) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "cpu")
                Text(getCore(server.host.cpu))
            }
            
            HStack {
                Image(systemName: "memorychip")
                Text("\(formatBytes(server.host.memTotal))")
            }
            
            HStack {
                Image(systemName: "internaldrive")
                Text("\(formatBytes(server.host.diskTotal))")
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "power")
                    Text("\(formatTimeInterval(seconds: server.status.uptime))")
                }
                
                HStack {
                    Image(systemName: "network")
                    VStack(alignment: .leading) {
                        Text("↑\(formatBytes(server.status.netOutTransfer))")
                        Text("↓\(formatBytes(server.status.netInTransfer))")
                    }
                }
            }
            .padding(.top, 5)
        }
        .frame(width: 100)
    }
}

struct WidgetApp: Widget {
    let kind: String = "nezha-widget-single-server"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.blue.gradient, for: .widget)
        }
        .configurationDisplayName("Nezha")
        .description("View your server at a glance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

//struct WidgetApp_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetEntryView(entry: ServerEntry(date: Date(), server: Server(id: 0, name: "Demo", ipv4: "1.1.1.1", ipv6: "1::", host: ServerHost(cpu: ["1 Virtual Core"], memTotal: 1024, diskTotal: 1024, countryCode: "US"), status: ServerStatus(cpu: 0.10, memUsed: 1024, diskUsed: 1024, netInTransfer: 1024, netOutTransfer: 1024, uptime: 60, load15: 0.10)), message: "Placeholder"))
//            .containerBackground(.blue.gradient, for: .widget)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
