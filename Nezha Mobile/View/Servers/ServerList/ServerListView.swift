//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    @State private var backgroundImage: UIImage?
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
        NavigationStack(path: Bindable(state).path) {
            ZStack {
                background
                    .zIndex(0)
                
                dashboard
                    .zIndex(1)
            }
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
            .navigationDestination(for: ServerData.self) { server in
                ServerDetailView(id: server.id)
            }
        }
        .onAppear {
            let backgroundPhotoData = NMCore.userDefaults.data(forKey: "NMBackgroundPhotoData")
            if let backgroundPhotoData {
                backgroundImage = UIImage(data: backgroundPhotoData)
            }
            else {
                backgroundImage = nil
            }
        }
        .onOpenURL { url in
            _ = NMCore.debugLog("Incoming Link Info - App was opened via URL: \(url)")
            handleIncomingURL(url)
        }
    }
    
    var background: some View {
        Group {
            if let backgroundImage {
                GeometryReader { proxy in
                    Image(uiImage: backgroundImage)
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
                groupPicker
                    .safeAreaPadding(.horizontal, 15)
                    .padding(.bottom, 5)
                
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
    
    var groupPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                groupTag(serverGroup: nil)
                ForEach(state.serverGroups) { serverGroup in
                    groupTag(serverGroup: serverGroup)
                }
            }
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
                .foregroundStyle(selectedServerGroup == serverGroup ? theme.themeActiveColor(scheme: scheme) : theme.themePrimaryColor(scheme: scheme))
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if selectedServerGroup == serverGroup {
                        Capsule()
                            .fill(theme.themeTintColor(scheme: scheme))
                            .matchedGeometryEffect(id: "ACTIVETAG", in: tagNamespace)
                    } else {
                        Capsule()
                            .fill(theme.themeSecondaryColor(scheme: scheme))
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
                                state.path.append(server)
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
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nezha" else {
            _ = NMCore.debugLog("Incoming Link Error - Invalid Scheme")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            _ = NMCore.debugLog("Incoming Link Error - Invalid URL")
            return
        }
        
        guard let action = components.host, action == "server-details" else {
            _ = NMCore.debugLog("Incoming Link Error - Unknown action")
            return
        }
        
        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            _ = NMCore.debugLog("Incoming Link Error - id is missing")
            return
        }
        
        let server = state.servers.first(where: { $0.id == id })
        state.tab = .alerts
        if let server {
            state.path.append(server)
        }
    }
}
