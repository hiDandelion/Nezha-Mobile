//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @AppStorage("NMTheme", store: NMCore.userDefaults) private var theme: NMTheme = .blue
    @State private var backgroundImage: UIImage?
    @State private var shouldNavigateToServerDetailView: Bool = false
    @State private var incomingURLServerUUID: String?
    @State private var searchText: String = ""
    @State private var selectedServerGroup: ServerGroup?
    @State private var newSettingRequireReconnection: Bool? = false
    @Namespace private var tagNamespace
    @Namespace private var serverNamespace
    
    private var filteredServers: [ServerData] {
        dashboardViewModel.servers
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
    
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 300, maximum: 400))]
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .zIndex(0)
                
                dashboard
                    .zIndex(1)
            }
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
            .navigationDestination(isPresented: $shouldNavigateToServerDetailView) {
                if let incomingURLServerUUID {
                    ServerDetailView(id: incomingURLServerUUID)
                }
            }
            .onAppear {
                withAnimation {
                    tabBarState.isServersViewVisible = true
                }
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isServersViewVisible = false
                }
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
                if themeStore.themeCustomizationEnabled {
                    themeStore.themeBackgroundColor(scheme: scheme)
                        .ignoresSafeArea()
                }
                else {
                    backgroundGradient(color: theme, scheme: scheme)
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    var dashboard: some View {
        Group {
            @Bindable var dashboardViewModel = dashboardViewModel
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
                        await dashboardViewModel.refresh()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .canInLoadingStateModifier(loadingState: dashboardViewModel.loadingState) {
                dashboardViewModel.startMonitoring()
            }
        }
    }
    
    var groupPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                groupTag(serverGroup: nil)
                ForEach(dashboardViewModel.serverGroups) { serverGroup in
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
            Text(serverGroup == nil ? String(localized: "All(\(dashboardViewModel.servers.count))") : nameCanBeUntitled(serverGroup!.name))
                .font(.callout)
                .foregroundStyle(selectedServerGroup == serverGroup ? (themeStore.themeCustomizationEnabled ? themeStore.themeActiveColor(scheme: scheme) : Color.white) : (themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary))
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if selectedServerGroup == serverGroup {
                        if themeStore.themeCustomizationEnabled {
                            Capsule()
                                .fill(themeStore.themeTintColor(scheme: scheme))
                                .matchedGeometryEffect(id: "ACTIVETAG", in: tagNamespace)
                        }
                        else {
                            Capsule()
                                .fill(themeColor(theme: theme))
                                .matchedGeometryEffect(id: "ACTIVETAG", in: tagNamespace)
                        }
                    } else {
                        if themeStore.themeCustomizationEnabled {
                            Capsule()
                                .fill(themeStore.themeSecondaryColor(scheme: scheme))
                        }
                        else {
                            Capsule()
                                .fill(.thinMaterial)
                        }
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    private var serverList: some View {
        Group {
            if !dashboardViewModel.servers.isEmpty {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredServers) { server in
                        if #available(iOS 18, *) {
                            NavigationLink {
                                ServerDetailView(id: server.id)
                                    .navigationTransition(.zoom(sourceID: server.id, in: serverNamespace))
                            } label: {
                                ServerCardView(lastUpdateTime: dashboardViewModel.lastUpdateTime, server: server)
                            }
                            .matchedTransitionSource(id: server.id, in: serverNamespace)
                            .buttonStyle(PlainButtonStyle())
                            .id(server.id)
                        }
                        else {
                            NavigationLink {
                                ServerDetailView(id: server.id)
                            } label: {
                                ServerCardView(lastUpdateTime: dashboardViewModel.lastUpdateTime, server: server)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id(server.id)
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
        
        incomingURLServerUUID = id
        tabBarState.activeTab = .servers
        shouldNavigateToServerDetailView = true
    }
}
