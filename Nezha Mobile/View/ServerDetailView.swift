//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import Charts

struct ServerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    var server: Server
    @State private var pingData: [PingData]?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
                    pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
                    pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
                    VStack(alignment: .leading) {
                        Label("Last Active", systemImage: "clock")
                        let lastActiveDateString = convertTimestampToLocalizedDateString(timestamp: server.lastActive)
                        Text("\(lastActiveDateString)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Host") {
                    VStack(alignment: .leading) {
                        Label("Operating System", systemImage: "opticaldisc")
                        HStack {
                            let OSName = server.host.platform
                            let OSVersion = server.host.platformVersion
                            if OSName.contains("debian") {
                                Image("DebianLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            if OSName.contains("ubuntu") {
                                Image("UbuntuLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            Text(OSName == "" ? String(localized: "Unknown") : "\(OSName.capitalizeFirstLetter()) \(OSVersion)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Label("CPU", systemImage: "cpu")
                        HStack {
                            let mainCPUInfo = server.host.cpu?.first
                            if let mainCPUInfo, mainCPUInfo.contains("AMD") {
                                Image("AMDLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            if let mainCPUInfo, mainCPUInfo.contains("Intel") {
                                Image("IntelLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            if let mainCPUInfo, mainCPUInfo.contains("Neoverse") {
                                Image("ARMLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            if let mainCPUInfo, mainCPUInfo.contains("Apple") {
                                Image("AppleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 50)
                            }
                            Text(mainCPUInfo ?? "N/A")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let mainGPUInfo = server.host.gpu?.first {
                        VStack(alignment: .leading) {
                            Label("GPU", systemImage: "cpu.fill")
                            HStack {
                                Text(mainGPUInfo)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    pieceOfInfo(systemImage: "triangle", name: "Architecture", content: Text("\(server.host.arch)"))
                    pieceOfInfo(systemImage: "cube.transparent", name: "Virtualization", content: Text("\(server.host.virtualization == "" ? String(localized: "Unknown") : server.host.virtualization)"))
                    pieceOfInfo(systemImage: "rectangle.2.swap", name: "Agent", content: Text("\(server.host.version)"))
                }
                
                Section("Status") {
                    let gaugeGradient = Gradient(colors: [.green, .blue, .pink])
                    
                    VStack {
                        HStack {
                            Label("CPU", systemImage: "cpu")
                            Spacer()
                            Text("\(server.status.cpu, specifier: "%.2f")%")
                                .foregroundStyle(.secondary)
                        }
                        
                        let cpuUsage = server.status.cpu / 100
                        Gauge(value: cpuUsage) {
                            
                        }
                        .gaugeStyle(AccessoryLinearGaugeStyle())
                        .tint(gaugeGradient)
                    }
                    
                    VStack {
                        HStack {
                            Label("Memory", systemImage: "memorychip")
                            Spacer()
                            Text("\(formatBytes(server.status.memUsed))/\(formatBytes(server.host.memTotal))")
                                .foregroundStyle(.secondary)
                        }
                        
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        Gauge(value: memUsage) {
                            
                        }
                        .gaugeStyle(AccessoryLinearGaugeStyle())
                        .tint(gaugeGradient)
                    }
                    
                    VStack {
                        if server.host.swapTotal != 0 {
                            HStack {
                                Label("Swap", systemImage: "doc")
                                Spacer()
                                Text("\(formatBytes(server.status.swapUsed))/\(formatBytes(server.host.swapTotal))")
                                    .foregroundStyle(.secondary)
                            }
                            
                            
                            let swapUsage = Double(server.status.swapUsed) / Double(server.host.swapTotal)
                            Gauge(value: swapUsage) {
                                
                            }
                            .gaugeStyle(AccessoryLinearGaugeStyle())
                            .tint(gaugeGradient)
                        }
                        else {
                            HStack {
                                Label("Swap", systemImage: "doc")
                                Spacer()
                                Text("Disabled")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Label("Disk", systemImage: "internaldrive")
                            Spacer()
                            Text("\(formatBytes(server.status.diskUsed))/\(formatBytes(server.host.diskTotal))")
                                .foregroundStyle(.secondary)
                        }
                        
                        let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                        Gauge(value: diskUsage) {
                            
                        }
                        .gaugeStyle(AccessoryLinearGaugeStyle())
                        .tint(gaugeGradient)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("Network", systemImage: "network")
                        Text("↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s")
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("Bandwidth", systemImage: "circle.dotted.circle")
                        Text("↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))")
                            .foregroundStyle(.secondary)
                    }
                    
                    pieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: "\(server.status.TCPConnectionCount)")
                    pieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: "\(server.status.UDPConnectionCount)")
                    pieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: "\(server.status.processCount)")
                }
                
                if let pingData {
                    Section("Ping") {
                        if pingData.isEmpty {
                            Text("No Data")
                        }
                        else {
                            ForEach(pingData) { data in
                                VStack {
                                    Text("\(data.monitorName)")
                                    Chart {
                                        ForEach(Array(zip(data.createdAt, data.avgDelay)), id: \.0) { timestamp, delay in
                                            LineMark(
                                                x: .value("Time", Date(timeIntervalSince1970: timestamp / 1000)),
                                                y: .value("Ping", delay)
                                            )
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { value in
                                            AxisGridLine()
                                            AxisValueLabel(format: .dateTime.hour())
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            RequestHandler.getServerPingData(id: String(server.id)) { response, errorDescription in
                if let response {
                    pingData = response.result
                }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                RequestHandler.getServerPingData(id: String(server.id)) { response, errorDescription in
                    if let response {
                        pingData = response.result
                    }
                }
            }
        }
    }
    
    private func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: String) -> some View {
        return HStack {
            Label(name, systemImage: systemImage)
            Spacer()
            Text(content)
                .foregroundStyle(.secondary)
        }
    }
    
    private func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: some View) -> some View {
        return HStack {
            Label(name, systemImage: systemImage)
            Spacer()
            content
                .foregroundStyle(.secondary)
        }
    }
}
