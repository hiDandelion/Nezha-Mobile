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
    @Bindable var dashboard: Dashboard
    @ObservedObject var dashboardViewModel: DashboardViewModel
    let serverId: Int
    
    var body: some View {
        let connectionURLString: String = "\(dashboard.ssl ? "wss" : "ws")://\(dashboard.link)/ws"
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
        
        NavigationStack {
            if let server = dashboardViewModel.servers[serverId] {
                Form {
                    Section("Basic") {
                        pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
                        pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
                        pieceOfInfo(systemImage: "power", name: "Boot Time", content: "\(formatTimeInterval(server.host.bootTime))")
                        if let lastActiveDate = dateFormatter.date(from: server.lastActive) {
                            VStack(alignment: .leading) {
                                Label("Last Active", systemImage: "clock")
                                Text(lastActiveDate.formatted(date: .numeric, time: .standard))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Section("State") {
                        pieceOfInfo(systemImage: "cpu", name: "CPU", content: Text("\(server.state.cpu, specifier: "%.2f")%"))
                        pieceOfInfo(systemImage: "memorychip", name: "Memory", content: "\(formatBytes(server.state.memUsed))/\(formatBytes(server.host.memTotal))")
                        pieceOfInfo(systemImage: "doc", name: "Swap", content: "\(formatBytes(server.state.swapUsed))/\(formatBytes(server.host.swapTotal))")
                        pieceOfInfo(systemImage: "internaldrive", name: "Disk", content: "\(formatBytes(server.state.diskUsed))/\(formatBytes(server.host.diskTotal))")
                        VStack(alignment: .leading) {
                            Label("Network", systemImage: "network")
                            Text("↓\(formatBytes(server.state.netInSpeed))/s ↑\(formatBytes(server.state.netOutSpeed))/s")
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading) {
                            Label("Bandwidth", systemImage: "circle.dotted.circle")
                            Text("↓\(formatBytes(server.state.netInTransfer)) ↑\(formatBytes(server.state.netOutTransfer))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section("Host") {
                        pieceOfInfo(systemImage: "opticaldisc", name: "OS", content: "\(server.host.platform) \(server.host.platformVersion)")
                        VStack(alignment: .leading) {
                            Label("CPU", systemImage: "cpu")
                            Text(server.host.cpu?.joined(separator: ", ") ?? "")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle(server.name)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                print("Scene Phase became active")
                dismiss()
            }
            if scenePhase == .background {
                dashboardViewModel.disconnect()
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
