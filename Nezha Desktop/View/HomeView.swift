//
//  HomeView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/21/24.
//

import SwiftUI

enum UserTab {
    case server
    case alert
}

struct UserSection: Hashable {
    let tab: UserTab
    let serverGroup: ServerGroup?
}

struct HomeView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var activeUserSection: UserSection = .init(tab: .server, serverGroup: nil)
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        NavigationSplitView {
            List(selection: $activeUserSection) {
                Section("Servers") {
                    Text("All")
                        .tag(UserSection(tab: .server, serverGroup: nil))
                    ForEach(dashboardViewModel.serverGroups) { serverGroup in
                        Text(nameCanBeUntitled(serverGroup.name))
                            .tag(UserSection(tab: .server, serverGroup: serverGroup))
                    }
                }
                
                Section("Alerts") {
                    Text("All")
                        .tag(UserSection(tab: .alert, serverGroup: nil))
                }
            }
            .listStyle(.sidebar)
        } detail: {
            switch(activeUserSection.tab) {
            case .server:
                ServerTableView(selectedServerGroup: activeUserSection.serverGroup)
            case .alert:
                AlertListView()
            }
        }
        .canInLoadingStateModifier(loadingState: $dashboardViewModel.loadingState, retryAction: {
            dashboardViewModel.startMonitoring()
        })
        .onAppear {
            if dashboardLink != "" && dashboardUsername != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
