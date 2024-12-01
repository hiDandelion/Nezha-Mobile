//
//  ServerTitle.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import SwiftUI

struct ServerTitle: View {
    let server: ServerData
    let lastUpdateTime: Date?
    
    var body: some View {
        HStack {
            if server.countryCode.uppercased() == "TW" {
                Text("🇹🇼")
            }
            else if server.countryCode.uppercased() != "" {
                Text(countryFlagEmoji(countryCode: server.countryCode))
            }
            else {
                Text("🏴‍☠️")
            }
            
            Text(server.name)
            
            if let lastUpdateTime {
                Image(systemName: "circlebadge.fill")
                    .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: lastUpdateTime) || server.status.uptime == 0 ? .red : .green)
            }
        }
    }
}
