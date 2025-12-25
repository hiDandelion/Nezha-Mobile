//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.colorScheme) private var scheme
    @Environment(NMState.self) private var state
    @State private var sortIndicator: SortIndicator = .index
    @State private var sortOrder: SortOrder = .descending
    @State private var searchText: String = ""
    @State private var selectedServerGroup: ServerGroup?
    @Namespace private var tagNamespace
    
    private var filteredServers: [ServerData] {
        state.servers
            .sorted {
                switch sortIndicator {
                case .index:
                    if $0.displayIndex == $1.displayIndex {
                        return sortOrder == .ascending ? $0.serverID < $1.serverID : $0.serverID > $1.serverID
                    }
                    return $0.displayIndex > $1.displayIndex
                case .uptime:
                    return sortOrder == .ascending ? $0.status.uptime < $1.status.uptime : $0.status.uptime > $1.status.uptime
                case .cpu:
                    return sortOrder == .ascending ? $0.status.cpuUsed < $1.status.cpuUsed : $0.status.cpuUsed > $1.status.cpuUsed
                case .memory:
                    let memoryUsage0 = ($0.host.memoryTotal == 0 ? 0 : Double($0.status.memoryUsed) / Double($0.host.memoryTotal))
                    let memoryUsage1 = ($1.host.memoryTotal == 0 ? 0 : Double($1.status.memoryUsed) / Double($1.host.memoryTotal))
                    return sortOrder == .ascending ? memoryUsage0 < memoryUsage1 : memoryUsage0 > memoryUsage1
                case .disk:
                    let diskUsage0 = ($0.host.diskTotal == 0 ? 0 : Double($0.status.diskUsed) / Double($0.host.diskTotal))
                    let diskUsage1 = ($1.host.diskTotal == 0 ? 0 : Double($1.status.diskUsed) / Double($1.host.diskTotal))
                    return sortOrder == .ascending ? diskUsage0 < diskUsage1 : diskUsage0 > diskUsage1
                case .send:
                    return sortOrder == .ascending ? $0.status.networkOut < $1.status.networkOut : $0.status.networkOut > $1.status.networkOut
                case .receive:
                    return sortOrder == .ascending ? $0.status.networkIn < $1.status.networkIn : $0.status.networkIn > $1.status.networkIn
                }
            }
            .filter {
                if let selectedServerGroup {
                    return selectedServerGroup.serverIDs.contains($0.serverID)
                }
                else {
                    return true
                }
            }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 320, maximum: 450))]
    
    var body: some View {
        NavigationStack {
            dashboard
        }
    }
    
    private var dashboard: some View {
        Group {
            Group {
                if !state.servers.isEmpty {
                    ScrollView {
                        groupPicker
                            .safeAreaPadding(.horizontal, 15)
                        
                        serverList
                    }
                    .navigationTitle("Servers")
                    .searchable(text: $searchText)
                    .toolbar {
                        ToolbarItem {
                            moreButton
                        }
                    }
                }
                else {
                    ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
                }
            }
            .loadingState(loadingState: state.dashboardLoadingState) {
                state.loadDashboard()
            }
        }
    }
    
    private var moreButton: some View {
        Menu("More", systemImage: "ellipsis") {
            Picker("Sort", selection: Binding(get: {
                sortIndicator
            }, set: { newValue in
                if sortIndicator == newValue {
                    switch(sortOrder) {
                    case .ascending:
                        sortOrder = .descending
                    case .descending:
                        sortOrder = .ascending
                    }
                }
                else {
                    sortIndicator = newValue
                }
            })) {
                ForEach(SortIndicator.allCases, id: \.self) { sortIndicator in
                    Button {
                        
                    } label: {
                        Text(sortIndicator.title)
                        if self.sortIndicator == sortIndicator && sortIndicator != .index {
                            Text(sortOrder.title)
                        }
                    }
                    .tag(sortIndicator)
                }
            }
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await state.refreshServerAndServerGroup()
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
    }
    
    private var groupPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                groupTag(serverGroup: nil)
                ForEach(state.serverGroups) { serverGroup in
                    groupTag(serverGroup: serverGroup)
                }
            }
            .padding(.vertical)
        }
        .scrollIndicators(.never)
    }
    
    private func groupTag(serverGroup: ServerGroup?) -> some View {
        Button(action: {
            withAnimation(.snappy) {
                selectedServerGroup = serverGroup
            }
        }) {
            Text(serverGroup == nil ? String(localized: "All(\(state.servers.count))") : nameCanBeUntitled(serverGroup!.name))
                .font(.callout)
                .foregroundStyle(Color.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if selectedServerGroup == serverGroup {
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
    
    private var serverList: some View {
        Group {
            if !state.servers.isEmpty {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredServers) { server in
                        ServerCardView(server: server, lastUpdateTime: state.dashboardLastUpdateTime)
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
