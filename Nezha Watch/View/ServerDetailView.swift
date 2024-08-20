//
//  ServerDetailView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ServerDetailView: View {
    var server: Server
    @State var isFromIncomingURL: Bool = false
    
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
                                pieceOfInfo(systemImage: "6.circle", name: "IPv6", content: "\(server.IPv6)")
                            }
                            pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
                            pieceOfInfo(systemImage: "clock", name: "Last Active", content: "\(convertTimestampToLocalizedDateString(timestamp: server.lastActive))")
                        }
                        
                        Section("Host") {
                            VStack(alignment: .leading) {
                                Label("Operating System", systemImage: "opticaldisc")
                                VStack {
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
                                VStack {
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
                            
                            VStack(alignment: .leading) {
                                Label("CPU", systemImage: "cpu")
                                Text("\(server.status.cpu, specifier: "%.2f")%")
                                    .foregroundStyle(.secondary)
                                
                                let cpuUsage = server.status.cpu / 100
                                Gauge(value: cpuUsage) {
                                    
                                }
                                .gaugeStyle(AccessoryLinearGaugeStyle())
                                .tint(gaugeGradient)
                            }
                            
                            VStack(alignment: .leading) {
                                Label("Memory", systemImage: "memorychip")
                                Text("\(formatBytes(server.status.memUsed))/\(formatBytes(server.host.memTotal))")
                                    .foregroundStyle(.secondary)
                                
                                let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                                Gauge(value: memUsage) {
                                    
                                }
                                .gaugeStyle(AccessoryLinearGaugeStyle())
                                .tint(gaugeGradient)
                            }
                            
                            VStack(alignment: .leading) {
                                if server.host.swapTotal != 0 {
                                    Label("Swap", systemImage: "doc")
                                    Text("\(formatBytes(server.status.swapUsed))/\(formatBytes(server.host.swapTotal))")
                                        .foregroundStyle(.secondary)
                                    
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
                            
                            VStack(alignment: .leading) {
                                Label("Disk", systemImage: "internaldrive")
                                Text("\(formatBytes(server.status.diskUsed))/\(formatBytes(server.host.diskTotal))")
                                    .foregroundStyle(.secondary)
                                
                                let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                                Gauge(value: diskUsage) {
                                    
                                }
                                .gaugeStyle(AccessoryLinearGaugeStyle())
                                .tint(gaugeGradient)
                            }
                            
                            pieceOfInfo(systemImage: "network", name: "Network", content: "↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s")
                            pieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Traffic", content: "↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))")
                            pieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: "\(server.status.TCPConnectionCount)")
                            pieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: "\(server.status.UDPConnectionCount)")
                            pieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: "\(server.status.processCount)")
                        }
                    }
                }
                else {
                    if #available(watchOS 10.0, *) {
                        ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                    }
                    else {
                        Text("Server Unavailable")
                    }
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
