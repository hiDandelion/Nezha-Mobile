//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    @State private var shouldNavigateToServerDetailView: Bool = false
    @State private var incomingURLServerID: Int?
    var dashboardViewModel: DashboardViewModel
    @AppStorage("NMTheme", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var theme: NMTheme = .blue
    @State private var backgroundImage: UIImage?
    @State private var searchText: String = ""
    @State private var activeTag: String = "All"
    @State private var newSettingRequireReconnection: Bool? = false
    @Namespace private var tagNamespace
    @Namespace private var serverNamespace
    
    private var filteredServers: [Server] {
        dashboardViewModel.servers
            .sorted { server1, server2 in
                switch (server1.displayIndex, server2.displayIndex) {
                case (.none, .none):
                    return server1.id < server2.id
                case (.none, .some):
                    return false
                case (.some, .none):
                    return true
                case let (.some(index1), .some(index2)):
                    return index1 > index2 || (index1 == index2 && server1.id < server2.id)
                }
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
                if let incomingURLServerID {
                    ServerDetailView(serverID: incomingURLServerID, dashboardViewModel: dashboardViewModel)
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
            let backgroundPhotoData = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.data(forKey: "NMBackgroundPhotoData")
            if let backgroundPhotoData {
                backgroundImage = UIImage(data: backgroundPhotoData)
            }
            else {
                backgroundImage = nil
            }
        }
        .onOpenURL { url in
            _ = debugLog("Incoming Link Info - App was opened via URL: \(url)")
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
                .foregroundStyle(activeTag == tag ? .white : (themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary))
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
                                ServerDetailView(serverID: server.id, dashboardViewModel: dashboardViewModel)
                                    .navigationTransition(.zoom(sourceID: server.id, in: serverNamespace))
                            } label: {
                                ServerCard(server: server)
                            }
                            .matchedTransitionSource(id: server.id, in: serverNamespace)
                            .buttonStyle(PlainButtonStyle())
                            .id(server.id)
                        }
                        else {
                            NavigationLink {
                                ServerDetailView(serverID: server.id, dashboardViewModel: dashboardViewModel)
                            } label: {
                                ServerCard(server: server)
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
    
    private func ServerCard(server: Server) -> some View {
        CardView {
            HStack {
                HStack {
                    HStack {
                        if server.host.countryCode.uppercased() == "TW" {
                            Image("TWFlag")
                                .resizable()
                                .scaledToFit()
                        }
                        else if server.host.countryCode.uppercased() != "" {
                            Text(countryFlagEmoji(countryCode: server.host.countryCode))
                        }
                        else {
                            Text("🏴‍☠️")
                        }
                    }
                    .frame(width: 20)
                    
                    Text(server.name)
                    
                    if let lastUpdateTime = dashboardViewModel.lastUpdateTime {
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive, lastUpdateTime: lastUpdateTime) || server.status.uptime == 0 ? .red : .green)
                    }
                }
                .font(.callout)
                
                Spacer()
                
                HStack {
                    Image(systemName: "power")
                    Text("\(formatTimeInterval(seconds: server.status.uptime))")
                }
                .font(.caption)
            }
        } contentView: {
            VStack {
                HStack {
                    HStack {
                        let cpuUsage = server.status.cpu / 100
                        let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.status.memUsed) / Double(server.host.memTotal))
                        let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.status.diskUsed) / Double(server.host.diskTotal))
                        
                        Gauge(value: cpuUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("CPU")
                                Text("\(cpuUsage * 100, specifier: "%.0f")%")
                            }
                        }
                        
                        Gauge(value: memUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("MEM")
                                Text("\(memUsage * 100, specifier: "%.0f")%")
                            }
                        }
                        
                        Gauge(value: diskUsage) {
                            
                        } currentValueLabel: {
                            VStack {
                                Text("DISK")
                                Text("\(diskUsage * 100, specifier: "%.0f")%")
                            }
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(themeStore.themeCustomizationEnabled ? themeStore.themeTintColor(scheme: scheme) : themeColor(theme: theme))
                    
                    VStack(alignment: .leading) {
                        if let core = getCore(server.host.cpu) {
                            HStack {
                                Image(systemName: "cpu")
                                    .frame(width: 10)
                                Text("\(core) Core")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            Image(systemName: "memorychip")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.memTotal))")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "internaldrive")
                                .frame(width: 10)
                            Text("\(formatBytes(server.host.diskTotal))")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "network")
                                    .frame(width: 10)
                                VStack(alignment: .leading) {
                                    Text("↑\(formatBytes(server.status.netOutSpeed))/s")
                                    Text("↓\(formatBytes(server.status.netInSpeed))/s")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                    }
                    .font(.caption2)
                    .frame(maxWidth: 100)
                    .padding(.leading, 20)
                }
            }
        } footerView: {
            HStack {
                let totalCore = Double(getCore(server.host.cpu) ?? 1)
                let loadPressure = server.status.load1 / totalCore
                
                Text("Load \(server.status.load1, specifier: "%.2f")")
                    .font(.caption2)
                
                Gauge(value: loadPressure <= 1 ? loadPressure : 1) {
                    
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(themeStore.themeCustomizationEnabled ? themeStore.themeTintColor(scheme: scheme) : themeColor(theme: theme))
            }
        }
        .if(themeStore.themeCustomizationEnabled) { view in
            view.foregroundStyle(themeStore.themePrimaryColor(scheme: scheme))
        }
        .if(themeStore.themeCustomizationEnabled) { view in
            view.background(themeStore.themeSecondaryColor(scheme: scheme))
        }
        .if(!themeStore.themeCustomizationEnabled) { view in
            view.background(.thinMaterial)
        }
        .cornerRadius(12)
        .contextMenu(ContextMenu(menuItems: {
            if server.IPv4 != "" {
                Button {
                    UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy IPv4", systemImage: "4.circle")
                }
            }
            if server.IPv6 != "" {
                Button {
                    UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy IPv6", systemImage: "6.circle")
                }
            }
        }))
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nezha" else {
            _ = debugLog("Incoming Link Error - Invalid Scheme")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            _ = debugLog("Incoming Link Error - Invalid URL")
            return
        }
        
        guard let action = components.host, action == "server-details" else {
            _ = debugLog("Incoming Link Error - Unknown action")
            return
        }
        
        guard let serverID = components.queryItems?.first(where: { $0.name == "serverID" })?.value else {
            _ = debugLog("Incoming Link Error - Server ID not found")
            return
        }
        
        incomingURLServerID = Int(serverID)
        tabBarState.activeTab = .servers
        shouldNavigateToServerDetailView = true
    }
}
