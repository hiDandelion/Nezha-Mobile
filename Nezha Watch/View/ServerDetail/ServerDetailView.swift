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
        TabView {
            MatrixGaugeView(title: "CPU", systemName: "cpu", percent: server.status.cpu, tintColor: .blue)
                .containerBackground(.blue.gradient, for: .tabView)
            MatrixGaugeView(title: "Memory", systemName: "memorychip", percent: Double(server.status.memUsed) / Double(server.host.memTotal) * 100, tintColor: .green)
                .containerBackground(.green.gradient, for: .tabView)
            MatrixGaugeView(title: "Disk", systemName: "internaldrive", percent: Double(server.status.diskUsed) / Double(server.host.diskTotal) * 100, tintColor: .orange)
                .containerBackground(.orange.gradient, for: .tabView)
            List {
                pieceOfInfo(systemImage: "network", name: "Network", content: "↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s")
                pieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Traffic", content: "↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))")
                pieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: "\(server.status.TCPConnectionCount)")
                pieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: "\(server.status.UDPConnectionCount)")
                pieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: "\(server.status.processCount)")
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(server.name)
        .onAppear {
            let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
            if let userDefaults {
                userDefaults.set(server.id, forKey: "NMWatchLastViewedServerID")
            }
        }
    }
}
