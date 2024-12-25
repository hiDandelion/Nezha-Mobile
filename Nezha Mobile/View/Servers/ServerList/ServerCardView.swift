//
//  ServerCardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/18/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerCardView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    let server: ServerData
    let lastUpdateTime: Date?
    
    var body: some View {
        ServerCard(server: server, lastUpdateTime: lastUpdateTime)
            .foregroundStyle(theme.themePrimaryColor(scheme: scheme))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.themeSecondaryColor(scheme: scheme))
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
            )
            .tint(theme.themeTintColor(scheme: scheme))
            .hoverEffect(.automatic)
            .contextMenu(ContextMenu(menuItems: {
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
            }))
    }
}
