//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ServerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    var server: Server
    
    var body: some View {
//        let dateFormatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
//            formatter.timeZone = TimeZone(abbreviation: "UTC")
//            return formatter
//        }()
        
        NavigationStack {
            Form {
                Section("Basic") {
                    pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
                    pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
                    pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
//                    if let lastActiveDate = dateFormatter.date(from: server.lastActive) {
//                        VStack(alignment: .leading) {
//                            Label("Last Active", systemImage: "clock")
//                            Text(lastActiveDate.formatted(date: .numeric, time: .standard))
//                                .foregroundStyle(.secondary)
//                        }
//                    }
                }
                
                Section("State") {
                    pieceOfInfo(systemImage: "cpu", name: "CPU", content: Text("\(server.status.cpu, specifier: "%.2f")%"))
                    pieceOfInfo(systemImage: "memorychip", name: "Memory", content: "\(formatBytes(server.status.memUsed))/\(formatBytes(server.host.memTotal))")
                    pieceOfInfo(systemImage: "doc", name: "Swap", content: "\(formatBytes(server.status.swapUsed))/\(formatBytes(server.host.swapTotal))")
                    pieceOfInfo(systemImage: "internaldrive", name: "Disk", content: "\(formatBytes(server.status.diskUsed))/\(formatBytes(server.host.diskTotal))")
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
                }
                
                Section("Host") {
                    pieceOfInfo(systemImage: "opticaldisc", name: "OS", content: "\(server.host.platform) \(server.host.platformVersion)")
                    VStack(alignment: .leading) {
                        Label("CPU", systemImage: "cpu")
                        Text(server.host.cpu?.joined(separator: ", ") ?? "N/A")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(server.name)
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
