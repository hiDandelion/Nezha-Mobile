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
    @AppStorage("NMTheme", store: NMCore.userDefaults) private var theme: NMTheme = .blue
    @State private var backgroundImage: UIImage?
    @State private var shouldNavigateToServerDetailView: Bool = false
    @State private var incomingURLServerUUID: String?
    var dashboardViewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var activeTag: String = "All"
    @State private var newSettingRequireReconnection: Bool? = false
    @Namespace private var tagNamespace
    @Namespace private var serverNamespace
    
    private var filteredServers: [ServerData] {
        dashboardViewModel.servers
            .sorted {
                if $0.displayIndex == $1.displayIndex {
                    return $0.serverID < $1.serverID
                }
                return $0.displayIndex < $1.displayIndex
            }
            .filter { activeTag == "All" || $0.tag == activeTag }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func columns(isWideLayout: Bool) -> [GridItem] {
        isWideLayout ? [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        : [GridItem(.flexible())]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background
                    .zIndex(0)
                
                Content
                    .zIndex(1)
            }
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
            .navigationDestination(isPresented: $shouldNavigateToServerDetailView) {
                if let incomingURLServerUUID {
                    ServerDetailView(dashboardViewModel: dashboardViewModel, id: incomingURLServerUUID)
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
            // Set background
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
    
    var Background: some View {
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
    
    var Content: some View {
        Group {
            switch(dashboardViewModel.loadingState) {
            case .idle:
                EmptyView()
            case .loading, .loaded:
                if dashboardViewModel.servers.isEmpty {
                    ProgressView("Loading...")
                }
                else {
                    GeometryReader { proxy in
                        let isWideLayout = proxy.size.width > 600
                        ScrollView {
                            GroupPicker
                                .safeAreaPadding(.horizontal, 15)
                                .padding(.bottom, 5)
                            
                            ServerList(isWideLayout: isWideLayout)
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
                    Button("Settings") {
                        tabBarState.activeTab = .settings
                    }
                }
                .padding()
            }
        }
    }
    
    var GroupPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                if !dashboardViewModel.servers.isEmpty {
                    let tags = Array(Set(dashboardViewModel.servers.map { $0.tag }))
                    let allTags = ["All"] + tags.sorted()
                    ForEach(allTags, id: \.self) { tag in
                        GroupTag(tag: tag)
                    }
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    private func GroupTag(tag: String) -> some View {
        Button(action: {
            withAnimation(.snappy) {
                activeTag = tag
            }
        }) {
            Text(tag == "All" ? String(localized: "All(\(dashboardViewModel.servers.count))") : (tag == "" ? String(localized: "Uncategorized") : tag))
                .font(.callout)
                .foregroundStyle(activeTag == tag ? (themeStore.themeCustomizationEnabled ? themeStore.themeActiveColor(scheme: scheme) : Color.white) : (themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary))
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if activeTag == tag {
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
    
    private func ServerList(isWideLayout: Bool) -> some View {
        Group {
            if !dashboardViewModel.servers.isEmpty {
                LazyVGrid(columns: columns(isWideLayout: isWideLayout), spacing: 10) {
                    ForEach(filteredServers) { server in
                        if #available(iOS 18, *) {
                            NavigationLink {
                                ServerDetailView(dashboardViewModel: dashboardViewModel, id: server.id)
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
                                ServerDetailView(dashboardViewModel: dashboardViewModel, id: server.id)
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
