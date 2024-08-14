//
//  ServerDetailBasicView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailBasicView: View {
    var server: Server
    
    var body: some View {
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
    }
}
