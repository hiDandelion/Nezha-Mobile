//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) var openWindow
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    var dashboardViewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var activeTag: String = "All"
    @Namespace private var tagNamespace
    
    private var filteredServers: [ServerData] {
        dashboardViewModel.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex < $1.displayIndex
            }
            .filter { server in
                return activeTag == "All" || dashboardViewModel.serverGroups.first(where: { $0.name == activeTag && $0.serverIDs.contains(server.serverID) }) != nil }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func columns(isWideLayout: Bool) -> [GridItem] {
        isWideLayout ? [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        : [GridItem(.flexible())]
    }
    
    var body: some View {
        NavigationStack {
            dashboard
        }
    }
    
    var dashboard: some View {
        Group {
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
            case .loaded:
                if dashboardViewModel.servers.isEmpty {
                    ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
                }
                else {
                    GeometryReader { proxy in
                        let isWideLayout = proxy.size.width > 600
                        ScrollView {
                            groupPicker
                                .safeAreaPadding(.horizontal, 15)
                            
                            serverList(isWideLayout: isWideLayout)
                        }
                        .navigationTitle("Servers")
                        .searchable(text: $searchText)
                        .toolbar {
                            Button {
                                dashboardViewModel.updateImmediately()
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                        }
                    }
                }
            case .error(let message):
                VStack(spacing: 20) {
                    Text("An error occurred")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                    Button("Retry") {
                        dashboardViewModel.startMonitoring()
                    }
                }
                .padding()
            }
        }
    }
    
    var groupPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                if !dashboardViewModel.servers.isEmpty {
                    let tags = Array(Set(dashboardViewModel.serverGroups.map { $0.name }))
                    let allTags = ["All"] + tags.sorted()
                    ForEach(allTags, id: \.self) { tag in
                        groupTag(tag: tag)
                    }
                }
            }
            .padding(.vertical)
        }
        .scrollIndicators(.never)
    }
    
    private func groupTag(tag: String) -> some View {
        Button(action: {
            withAnimation(.snappy) {
                activeTag = tag
            }
        }) {
            Text(tag == "All" ? String(localized: "All(\(dashboardViewModel.servers.count))") : (tag == "" ? String(localized: "Uncategorized") : tag))
                .font(.callout)
                .foregroundStyle(Color.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if activeTag == tag {
                        Capsule()
                            .fill(.thickMaterial)
                    } else {
                        Capsule()
                            .fill(.thinMaterial)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    private func serverList(isWideLayout: Bool) -> some View {
        Group {
            if !dashboardViewModel.servers.isEmpty {
                LazyVGrid(columns: columns(isWideLayout: isWideLayout), spacing: 10) {
                    ForEach(filteredServers) { server in
                        ServerCardView(lastUpdateTime: dashboardViewModel.lastUpdateTime, server: server)
                            .onTapGesture {
                                openWindow(id: "server-detail-view", value: server.id)
                            }
                    }
                }
                .padding(.horizontal, 15)
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
}
