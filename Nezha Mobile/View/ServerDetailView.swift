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
    @State private var pingDatas: [PingData]?
    @State private var errorDescriptionLoadingPingData: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if server.status.uptime != 0 {
                    Form {
                        Section("Basic") {
                            pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
                            pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
                            pieceOfInfo(systemImage: "4.circle", name: "IPv4", content: "\(server.IPv4)")
                            if server.IPv6 != "" {
                                pieceOfInfo(systemImage: "6.circle", name: "IPv6", content: "\(server.IPv6)", isLongContent: true)
                            }
                            pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
                            pieceOfInfo(systemImage: "clock", name: "Last Active", content: "\(convertTimestampToLocalizedDateString(timestamp: server.lastActive))", isLongContent: true)
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
                                    if OSName.contains("darwin") {
                                        Image("macOSLogo")
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
                                    Text(mainCPUInfo ?? String(localized: "N/A"))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if let mainGPUInfo = server.host.gpu?.first {
                                pieceOfInfo(systemImage: "cpu.fill", name: "GPU", content: Text("\(mainGPUInfo)"))
                            }
                            
                            pieceOfInfo(systemImage: "triangle", name: "Architecture", content: Text("\(server.host.arch)"))
                            pieceOfInfo(systemImage: "cube.transparent", name: "Virtualization", content: Text("\(server.host.virtualization == "" ? String(localized: "Unknown") : server.host.virtualization)"))
                            pieceOfInfo(systemImage: "rectangle.2.swap", name: "Agent", content: Text("\(server.host.version)"))
                        }
                        
                        Section("Status") {
                            let gaugeGradient = Gradient(colors: [.green, .pink])
                            
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
                                    pieceOfInfo(systemImage: "doc", name: "Swap", content: String(localized: "Disabled"))
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
                            
                            pieceOfInfo(systemImage: "network", name: "Network", content: "↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s", isLongContent: true)
                            pieceOfInfo(systemImage: "circle.dotted.circle", name: "Bandwidth", content: "↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))", isLongContent: true)
                            pieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: "\(server.status.TCPConnectionCount)")
                            pieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: "\(server.status.UDPConnectionCount)")
                            pieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: "\(server.status.processCount)")
                        }
                        
                        Section("Ping") {
                            if let pingDatas {
                                ForEach(pingDatas) { pingData in
                                    PingChart(pingData: pingData)
                                }
                            }
                            else if let errorDescriptionLoadingPingData {
                                Text(errorDescriptionLoadingPingData)
                            }
                        }
                    }
                }
                else {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                    }
                    else {
                        // ContentUnavailableView ×
                        Text("Server Unavailable")
                    }
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                do {
                    let response = try await RequestHandler.getServerPingData(serverID: String(server.id))
                    withAnimation {
                        errorDescriptionLoadingPingData = nil
                        pingDatas = response.result
                    }
                }
                catch {
                    errorDescriptionLoadingPingData = error.localizedDescription
                }
            }
        }
        .onChange(of: scenePhase) { _ in
            if scenePhase == .active {
                Task {
                    do {
                        let response = try await RequestHandler.getServerPingData(serverID: String(server.id))
                        withAnimation {
                            errorDescriptionLoadingPingData = nil
                            pingDatas = response.result
                        }
                    }
                    catch {
                        errorDescriptionLoadingPingData = error.localizedDescription
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
    
    private func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: String, isLongContent: Bool = false) -> some View {
        VStack {
            if isLongContent {
                VStack(alignment: .leading) {
                    Label(name, systemImage: systemImage)
                    Text(content)
                        .foregroundStyle(.secondary)
                }
            }
            else {
                HStack {
                    Label(name, systemImage: systemImage)
                    Spacer()
                    Text(content)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: some View, isLongContent: Bool = false) -> some View {
        VStack {
            if isLongContent {
                VStack(alignment: .leading) {
                    Label(name, systemImage: systemImage)
                    Spacer()
                    content
                        .foregroundStyle(.secondary)
                }
            }
            else {
                HStack {
                    Label(name, systemImage: systemImage)
                    Spacer()
                    content
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
