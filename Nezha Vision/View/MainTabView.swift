//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case servers = "servers"
    case tools = "tools"
    case alerts = "alerts"
    case settings = "settings"
    
    var systemName: String {
        switch self {
        case .servers: "server.rack"
        case .tools: "briefcase"
        case .alerts: "bell"
        case .settings: "gearshape"
        }
    }
    
    var title: String {
        switch self {
        case .servers: String(localized: "Servers")
        case .tools: String(localized: "Tools")
        case .alerts: String(localized: "Alerts")
        case .settings: String(localized: "Settings")
        }
    }
}

struct MainTabView: View {
    @Environment(NMState.self) var state
    
    var body: some View {
        TabView(selection: Bindable(state).tab) {
            Tab(value: MainTab.servers) {
                ServerListView()
            } label: {
                Image(systemName: MainTab.servers.systemName)
            }

            Tab(value: MainTab.tools) {
                ToolListView()
            } label: {
                Image(systemName: MainTab.tools.systemName)
            }
            
            Tab(value: MainTab.settings) {
                SettingsView()
            } label: {
                Image(systemName: MainTab.settings.systemName)
            }
        }
    }
}
