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
    @State private var searchText: String = ""
    @State private var selectedServerGroup: ServerGroup?
    @Namespace private var tagNamespace
    
    private var filteredServers: [ServerData] {
        state.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex > $1.displayIndex
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
    
    var dashboard: some View {
        Group {
            Group {
                if !state.servers.isEmpty {
                    GeometryReader { proxy in
                        let isWideLayout = proxy.size.width > 600
                        ScrollView {
                            groupPicker
                                .safeAreaPadding(.horizontal, 15)
                            
                            serverList
                        }
                        .navigationTitle("Servers")
                        .searchable(text: $searchText)
                        .toolbar {
                            Button {
                                Task {
                                    await state.refreshServerAndServerGroup()
                                }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                        }
                    }
                }
                else {
                    ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
                }
            }
            .canInLoadingStateModifier(loadingState: state.dashboardLoadingState) {
                state.loadDashboard()
            }
        }
    }
    
    var groupPicker: some View {
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
