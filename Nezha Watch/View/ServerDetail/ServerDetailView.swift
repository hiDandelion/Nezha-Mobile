//
//  ServerDetailView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ServerDetailView: View {
    var server: ServerData
    @State var isFromIncomingURL: Bool = false
    
    var body: some View {
        TabView {
            MatrixGaugeView(title: "CPU", systemName: "cpu", percent: server.status.cpuUsed, tintColor: .blue)
                .containerBackground(.blue.gradient, for: .tabView)
            MatrixGaugeView(title: "Memory", systemName: "memorychip", percent: Double(server.status.memoryUsed) / Double(server.host.memoryTotal) * 100, tintColor: .green)
                .containerBackground(.green.gradient, for: .tabView)
            MatrixGaugeView(title: "Disk", systemName: "internaldrive", percent: Double(server.status.diskUsed) / Double(server.host.diskTotal) * 100, tintColor: .orange)
                .containerBackground(.orange.gradient, for: .tabView)
            List {
                NMUI.PieceOfInfo(systemImage: "network", name: "Network Send/Receive", content: Text("↓ \(formatBytes(server.status.networkInSpeed))/s ↑ \(formatBytes(server.status.networkOutSpeed))/s"))
                NMUI.PieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Data", content: Text("↓ \(formatBytes(server.status.networkIn)) ↑ \(formatBytes(server.status.networkOut))"))
                NMUI.PieceOfInfo(systemImage: "point.3.filled.connected.trianglepath.dotted", name: "TCP Connection", content: Text("\(server.status.tcpConnectionCount)"))
                NMUI.PieceOfInfo(systemImage: "point.3.connected.trianglepath.dotted", name: "UDP Connection", content: Text("\(server.status.udpConnectionCount)"))
                NMUI.PieceOfInfo(systemImage: "square.split.2x2", name: "Process", content: Text("\(server.status.processCount)"))
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(server.name)
        .onAppear {
            NMCore.userDefaults.set(server.id, forKey: "NMWatchLastViewedServerID")
        }
    }
}
