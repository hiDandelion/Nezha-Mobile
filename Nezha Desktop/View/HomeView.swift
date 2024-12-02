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
    let tag: String
}

struct HomeView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var activeUserSection: UserSection = UserSection(tab: .server, tag: "All")
    private var activeServerTag: String? {
        activeUserSection.tab == .server ? activeUserSection.tag : nil
    }
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        NavigationSplitView {
            List(selection: $activeUserSection) {
                Section("Servers") {
                    if !dashboardViewModel.servers.isEmpty {
                        let tags = Array(Set(dashboardViewModel.serverGroups.map { $0.name }))
                        let allTags = ["All"] + tags.sorted()
                        ForEach(allTags, id: \.self) { tag in
                            Text("\(tag == "All" ? String(localized: "All") : (tag == "" ? String(localized: "Untitled") : tag))")
                                .tag(UserSection(tab: .server, tag: tag))
                        }
                    }
                }
                
                Section("Alerts") {
                    Text("All")
                        .tag(UserSection(tab: .alert, tag: "All"))
                }
            }
            .listStyle(.sidebar)
        } detail: {
            switch(activeUserSection.tab) {
            case .server:
                if let activeServerTag {
                    ServerTableView(activeTag: activeServerTag)
                }
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
