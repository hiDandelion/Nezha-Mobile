//
//  DashboardDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct DashboardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    var dashboardLink: String
    var dashboardAPIToken: String
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var servers: [(key: Int, value: Server)] = []
    @AppStorage("NMTheme", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var theme: NMTheme = .blue
    @State private var navigationBarHeight: CGFloat = 0.0
    @FocusState private var isSearching: Bool
    @State private var searchText: String = ""
    @State private var activeTag: String = String(localized: "All")
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    @Namespace private var animation
    
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
            VStack {
                switch(dashboardViewModel.loadingState) {
                case .idle:
                    ZStack {
                        backgroundGradient(color: theme, scheme: scheme)
                            .ignoresSafeArea()
                    }
                case .loading, .loaded:
                    ZStack {
                        backgroundGradient(color: theme, scheme: scheme)
                            .ignoresSafeArea()
                        
                        if dashboardViewModel.servers.isEmpty {
                            ProgressView("Loading...")
                        }
                        else {
                            GeometryReader { proxy in
                                let isWideLayout = proxy.size.width > 600
                                
                                ScrollView {
                                    ExpandableNavigationBar(isLoading: dashboardViewModel.loadingState == .loading)
                                        .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
                                        .zIndex(1)
                                    
                                    ServerList(isWideLayout: isWideLayout)
                                        .padding(.top, isSearching ?  navigationBarHeight - 50 : navigationBarHeight - 5)
                                        .zIndex(0)
                                }
                                .coordinateSpace(name: "scrollView")
                                .toolbar(.hidden, for: .navigationBar)
                                .scrollIndicators(.never)
                            }
                        }
                    }
                case .error(let message):
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 20) {
                            Text("An error occured")
                                .font(.headline)
                            Text(message)
                                .font(.subheadline)
                            Button("Retry") {
                                dashboardViewModel.startMonitoring()
                            }
                            Button("Settings") {
                                isShowingSettingSheet.toggle()
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbarBackground(.hidden)
            .sheet(isPresented: $isShowingSettingSheet) {
                SettingView(dashboardViewModel: dashboardViewModel)
            }
        }
        .onAppear {
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
    
    func ExpandableNavigationBar(title: String = "Dashboard", isLoading: Bool = false) -> some View {
        GeometryReader { proxy in
            let minY = getScrollViewMinY(proxy: proxy)
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            
            if #available(iOS 17.0, *) {
                VStack(spacing: 15 - (progress * 15)) {
                    Title(title: title, isLoading: isLoading, progress: progress)
                    
                    SearchBar(progress: progress)
                    
                    GroupPicker()
                }
                .padding(.top, 15)
                .safeAreaPadding(.horizontal, 15)
                .offset(y: minY < 0 || isSearching ? -minY : 0)
                .offset(y: -progress * 65)
                .overlay(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: NavigationBarHeightPreferenceKey.self, value: proxy.size.height)
                    }
                )
                .onPreferenceChange(NavigationBarHeightPreferenceKey.self) { height in
                    navigationBarHeight = height
                }
            }
            else {
                VStack(spacing: 15 - (progress * 15)) {
                    Title(title: title, isLoading: isLoading, progress: progress)
                    
                    SearchBar(progress: progress)
                    
                    GroupPicker()
                }
                .padding(.top, 15)
                // safeAreaPadding → padding
                .padding(.horizontal, 15)
                .offset(y: minY < 0 || isSearching ? -minY : 0)
                .offset(y: -progress * 65)
                .overlay(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: NavigationBarHeightPreferenceKey.self, value: proxy.size.height)
                    }
                )
                .onPreferenceChange(NavigationBarHeightPreferenceKey.self) { height in
                    navigationBarHeight = height
                }
            }
        }
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
    
    private func Title(title: String = "Dashboard", isLoading: Bool = false, progress: CGFloat) -> some View {
        HStack {
            HStack {
                Text(title)
                    .font(.largeTitle.bold())
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                isShowingSettingSheet = true
            } label: {
                Image(systemName: "gear")
                    .padding(10)
                    .foregroundStyle(Color.primary)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
            }
        }
        .opacity(1 - progress)
    }
    
    private func SearchBar(progress: CGFloat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
            
            TextField("Search Server", text: $searchText)
                .focused($isSearching)
            
            if isSearching || searchText != "" {
                Button(action: {
                    withAnimation {
                        isSearching = false
                        searchText = ""
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                })
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 15 - (progress * 15))
        .frame(height: 45)
        .clipShape(.capsule)
        .background {
            RoundedRectangle(cornerRadius: 25 - (progress * 25))
                .fill(.ultraThinMaterial)
                .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                .padding(.top, -progress * 165)
                .padding(.bottom, -progress * 45)
                .padding(.horizontal, -progress * 15)
        }
    }
    
    private func GroupPicker() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                if !dashboardViewModel.servers.isEmpty {
                    let tags = Array(Set(dashboardViewModel.servers.map { $0.tag }))
                    let allTags = [String(localized: "All")] + tags.sorted()
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
            Text(tag == "" ? String(localized: "Uncategorized") : tag)
                .font(.callout)
                .foregroundStyle(activeTag == tag ? (scheme == .dark ? .black : .white) : Color.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if activeTag == tag {
                        Capsule()
                            .fill(Color.primary)
                            .matchedGeometryEffect(id: "ACTIVETAGTAB", in: animation)
                    } else {
                        Capsule()
                            .fill(.regularMaterial)
                    }
                }
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private func ServerList(isWideLayout: Bool) -> some View {
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                LazyVGrid(columns: columns(isWideLayout: isWideLayout), spacing: 10) {
                    ForEach(filteredServers) { server in
                        NavigationLink {
                            ServerDetailView(server: server)
                        } label: {
                            ServerCard(server: server)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(server.id)
                    }
                }
                .padding(.horizontal, 15)
            }
            else {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
                }
                else {
                    // ContentUnavailableView ×
                    Text("No Server")
                }
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
                    Image(systemName: "circlebadge.fill")
                        .foregroundStyle(isServerOnline(timestamp: server.lastActive) || server.status.uptime == 0 ? .red : .green)
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
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "cpu")
                                .frame(width: 10)
                            Text(getCore(server.host.cpu))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
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
                let totalCore = getCore(server.host.cpu).toDouble()
                let loadPressure = server.status.load1 / (totalCore ?? 1.0)
                
                Text("Load \(server.status.load1, specifier: "%.2f")")
                    .font(.caption2)
                
                Gauge(value: loadPressure <= 1 ? loadPressure : 1) {
                    
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
        }
    }
    
    func getScrollViewMinY(proxy: GeometryProxy) -> CGFloat {
        if #available(iOS 17.0, *) {
            return proxy.frame(in: .scrollView(axis: .vertical)).minY
        }
        else {
            return proxy.frame(in: .named("scrollView")).minY
        }
    }
    
    struct NavigationBarHeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}
