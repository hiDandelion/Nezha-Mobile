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
    var dashboardViewModel: DashboardViewModel
    @State private var activeUserSection: UserSection = UserSection(tab: .server, tag: "All")
    private var activeServerTag: String? {
        activeUserSection.tab == .server ? activeUserSection.tag : nil
    }
    
    var body: some View {
        VStack {
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
            case .loaded:
                NavigationSplitView {
                    List(selection: $activeUserSection) {
                        Section("Servers") {
                            if !dashboardViewModel.servers.isEmpty {
                                let tags = Array(Set(dashboardViewModel.servers.map { $0.tag }))
                                let allTags = ["All"] + tags.sorted()
                                ForEach(allTags, id: \.self) { tag in
                                    Text("\(tag == "All" ? String(localized: "All") : (tag == "" ? String(localized: "Uncategorized") : tag))")
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
                            ServerTableView(dashboardViewModel: dashboardViewModel, activeTag: activeServerTag)
                        }
                    case .alert:
                        AlertListView()
                    }
                }
            case .error(let message):
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 20) {
                        Text("An error occurred")
                            .font(.headline)
                        Text(message)
                            .font(.subheadline)
                        Button("Retry") {
                            dashboardViewModel.startMonitoring()
                        }
                        SettingsLink(label: {
                            Text("Settings")
                        })
                    }
                    .padding()
                }
            }
        }
    }
}
