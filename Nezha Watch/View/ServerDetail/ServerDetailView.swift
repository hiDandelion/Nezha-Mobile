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
                PieceOfInfo(systemImage: "network", name: "Network", content: Text("↓\(formatBytes(server.status.netInSpeed))/s ↑\(formatBytes(server.status.netOutSpeed))/s"))
                PieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Traffic", content: Text("↓\(formatBytes(server.status.netInTransfer)) ↑\(formatBytes(server.status.netOutTransfer))"))
                PieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: Text("\(server.status.TCPConnectionCount)"))
                PieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: Text("\(server.status.UDPConnectionCount)"))
                PieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: Text("\(server.status.processCount)"))
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(server.name)
        .onAppear {
            UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.set(server.id, forKey: "NMWatchLastViewedServerID")
        }
    }
}
