//
//  HomeView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/21/24.
//

import SwiftUI

enum UserTab {
    case servers
    case dashboard
    case terminal
}

enum Tool {
    case serverGroups
    case monitors
    case notifications
    case snippets
}

struct UserSection: Hashable {
    let tab: UserTab
    let serverGroup: ServerGroup?
    let tool: Tool?
}

struct HomeView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var activeUserSection: UserSection = .init(tab: .servers, serverGroup: nil, tool: nil)
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        NavigationSplitView {
            List(selection: $activeUserSection) {
                Section("Servers") {
                    Text("All")
                        .tag(UserSection(tab: .servers, serverGroup: nil, tool: nil))
                    ForEach(dashboardViewModel.serverGroups) { serverGroup in
                        Text(nameCanBeUntitled(serverGroup.name))
                            .tag(UserSection(tab: .servers, serverGroup: serverGroup, tool: nil))
                    }
                }
                
                Section("Dashboard") {
                    Text("Server Groups")
                        .tag(UserSection(tab: .dashboard, serverGroup: nil, tool: .serverGroups))
                    Text("Monitors")
                        .tag(UserSection(tab: .dashboard, serverGroup: nil, tool: .monitors))
                    Text("Notifications")
                        .tag(UserSection(tab: .dashboard, serverGroup: nil, tool: .notifications))
                }
                
                Section("Terminal") {
                    Text("Snippets")
                        .tag(UserSection(tab: .terminal, serverGroup: nil, tool: .snippets))
                }
            }
            .listStyle(.sidebar)
        } detail: {
            switch(activeUserSection.tab) {
            case .servers:
                ServerTableView(selectedServerGroup: activeUserSection.serverGroup)
            case .dashboard, .terminal:
                switch(activeUserSection.tool) {
                case .serverGroups:
                    NavigationStack {
                        ServerGroupListView()
                    }
                case .monitors:
                    NavigationStack {
                        ServiceListView()
                    }
                case .notifications:
                    NavigationStack {
                        NotificationView()
                    }
                case .snippets:
                    NavigationStack {
                        SnippetListView(executeAction: nil)
                    }
                case .none:
                    EmptyView()
                }
            }
        }
        .canInLoadingStateModifier(loadingState: dashboardViewModel.loadingState, retryAction: {
            dashboardViewModel.startMonitoring()
        })
    }
}
