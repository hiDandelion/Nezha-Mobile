//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/25/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    @State private var backgroundImage: NSImage?
    @State private var searchText: String = ""
    var selectedServerGroup: ServerGroup?
    
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
        NavigationStack(path: Bindable(state).path) {
            ZStack {
                background
                    .zIndex(0)
                
                dashboard
                    .zIndex(1)
            }
            .navigationDestination(for: ServerData.self) { server in
                ServerDetailView(id: server.id)
            }
        }
        .onAppear {
            let backgroundPhotoData = NMCore.userDefaults.data(forKey: "NMBackgroundPhotoData")
            if let backgroundPhotoData {
                backgroundImage = NSImage(data: backgroundPhotoData)
            }
            else {
                backgroundImage = nil
            }
        }
    }
    
    var background: some View {
        Group {
            if let backgroundImage {
                GeometryReader { proxy in
                    Image(nsImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: proxy.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
            }
            else {
                theme.themeBackgroundColor(scheme: scheme)
                    .ignoresSafeArea()
            }
        }
    }
    
    var dashboard: some View {
        Group {
            ScrollView {
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
            .loadingState(loadingState: state.dashboardLoadingState) {
                state.loadDashboard()
            }
        }
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
                .padding(.vertical, 15)
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
}
