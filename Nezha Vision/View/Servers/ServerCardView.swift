//
//  ServerCardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/25/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerCardView: View {
    let server: ServerData
    let lastUpdateTime: Date?
    
    var body: some View {
        ServerCard(server: server, lastUpdateTime: lastUpdateTime)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
            )
            .hoverEffect(.automatic)
            .contextMenu(
                ContextMenu(menuItems: {
                    if server.ipv4 != "" {
                        Button {
                            UIPasteboard.general.string = server.ipv4
                        } label: {
                            Label("Copy IPv4", systemImage: "4.circle")
                        }
                    }
                    if server.ipv6 != "" {
                        Button {
                            UIPasteboard.general.string = server.ipv6
                        } label: {
                            Label("Copy IPv6", systemImage: "6.circle")
                        }
                    }
                })
            )
    }
}
