//
//  HomeView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
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

struct HomeView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: Bindable(state).tab) {
                Tab(value: MainTab.servers) {
                    if state.isShowMapView {
                        ServerMapView()
                    }
                    else {
                        ServerListView()
                    }
                } label: {
                    Label(MainTab.servers.title, systemImage: MainTab.servers.systemName)
                }
                
                Tab(value: MainTab.tools) {
                    ToolListView()
                } label: {
                    Label(MainTab.tools.title, systemImage: MainTab.tools.systemName)
                }
                
                Tab(value: MainTab.alerts) {
                    AlertListView()
                } label: {
                    Label(MainTab.alerts.title, systemImage: MainTab.alerts.systemName)
                }
                
                Tab(value: MainTab.settings) {
                    SettingsView()
                } label: {
                    Label(MainTab.settings.title, systemImage: MainTab.settings.systemName)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
        }
        else {
            TabView(selection: Bindable(state).tab) {
                Group {
                    if state.isShowMapView {
                        ServerMapView()
                    }
                    else {
                        ServerListView()
                    }
                }
                .tag(MainTab.servers)
                .tabItem {
                    Label(MainTab.servers.title, systemImage: MainTab.servers.systemName)
                }
                
                ToolListView()
                    .tag(MainTab.tools)
                    .tabItem {
                        Label(MainTab.tools.title, systemImage: MainTab.tools.systemName)
                    }
                
                AlertListView()
                    .tag(MainTab.alerts)
                    .tabItem {
                        Label(MainTab.alerts.title, systemImage: MainTab.alerts.systemName)
                    }
                
                SettingsView()
                    .tag(MainTab.settings)
                    .tabItem {
                        Label(MainTab.settings.title, systemImage: MainTab.settings.systemName)
                    }
            }
        }
    }
}
