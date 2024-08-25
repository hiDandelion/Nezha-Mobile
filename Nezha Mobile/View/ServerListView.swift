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
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @AppStorage("NMTheme", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var theme: NMTheme = .blue
    @ObservedObject var themeStore: ThemeStore
    @State private var backgroundImage: UIImage?
    @State private var navigationBarHeight: CGFloat = 0.0
    @FocusState private var isSearching: Bool
    @State private var searchText: String = ""
    @State private var activeTag: String = "All"
    @Binding var isShowingServerMapView: Bool
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
                ZStack {
                    // Background
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
                                    ExpandableNavigationBar
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
                                isShowingSettingSheet.toggle()
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbarBackground(.hidden)
            .sheet(isPresented: $isShowingSettingSheet) {
                SettingView(dashboardViewModel: dashboardViewModel, backgroundImage: $backgroundImage, themeStore: themeStore)
            }
        }
        .onAppear {
            // Set background
            let backgroundPhotoData = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.data(forKey: "NMBackgroundPhotoData")
            if let backgroundPhotoData {
                backgroundImage = UIImage(data: backgroundPhotoData)
            }
        }
    }
    
    var ExpandableNavigationBar: some View {
        GeometryReader { proxy in
            let minY = getScrollViewMinY(proxy: proxy)
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            
            if #available(iOS 17.0, *) {
                VStack(spacing: 15 - (progress * 15)) {
                    Title(progress: progress)
                    
                    SearchBar(progress: progress)
                    
                    GroupPicker
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
                    Title(progress: progress)
                    
                    SearchBar(progress: progress)
                    
                    GroupPicker
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
    
    private func Title(title: String = "Servers", progress: CGFloat) -> some View {
        HStack {
            HStack {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary)
                    .if(backgroundImage != nil) { view in
                        view
                            .padding(.horizontal, 10)
                            .background {
                                if themeStore.themeCustomizationEnabled {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(themeStore.themeSecondaryColor(scheme: scheme))
                                }
                                else {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(.thinMaterial)
                                }
                            }
                    }
                ProgressView()
                    .opacity(dashboardViewModel.loadingState == .loading ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                withAnimation {
                    isShowingServerMapView = true
                }
            } label: {
                Image(systemName: "map")
                    .padding(10)
                    .foregroundStyle(themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary)
                    .if(themeStore.themeCustomizationEnabled) { view in
                        view.background(themeStore.themeSecondaryColor(scheme: scheme))
                    }
                    .if(!themeStore.themeCustomizationEnabled) { view in
                        view.background(.thinMaterial)
                    }
                    .clipShape(Circle())
            }
            .hoverEffect(.lift)
            
            Button {
                isShowingSettingSheet = true
            } label: {
                Image(systemName: "gear")
                    .padding(10)
                    .foregroundStyle(themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary)
                    .if(themeStore.themeCustomizationEnabled) { view in
                        view.background(themeStore.themeSecondaryColor(scheme: scheme))
                    }
                    .if(!themeStore.themeCustomizationEnabled) { view in
                        view.background(.thinMaterial)
                    }
                    .clipShape(Circle())
            }
            .hoverEffect(.lift)
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
            if themeStore.themeCustomizationEnabled {
                RoundedRectangle(cornerRadius: 25 - (progress * 25))
                    .fill(themeStore.themeSecondaryColor(scheme: scheme))
                    .if(progress == 1) { view in
                        view.shadow(color: .gray.opacity(0.25), radius: 5, x: 2, y: 2)
                    }
                    .padding(.top, -progress * 165)
                    .padding(.bottom, -progress * 45)
                    .padding(.horizontal, -progress * 15)
            }
            else {
                RoundedRectangle(cornerRadius: 25 - (progress * 25))
                    .fill(.thinMaterial)
                    .if(progress == 1) { view in
                        view.shadow(color: .gray.opacity(0.25), radius: 5, x: 2, y: 2)
                    }
                    .padding(.top, -progress * 165)
                    .padding(.bottom, -progress * 45)
                    .padding(.horizontal, -progress * 15)
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
            Text(tag == "All" ? String(localized: "All") : (tag == "" ? String(localized: "Uncategorized") : tag))
                .font(.callout)
                .foregroundStyle(activeTag == tag ? (themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColorDark : (scheme == .light ? .white : .black)) : (themeStore.themeCustomizationEnabled ? themeStore.themePrimaryColor(scheme: scheme) : Color.primary))
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if activeTag == tag {
                        if themeStore.themeCustomizationEnabled {
                            Capsule()
                                .fill(themeStore.themeTintColor(scheme: scheme))
                                .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
                        }
                        else {
                            Capsule()
                                .fill(Color.primary)
                                .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
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
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                LazyVGrid(columns: columns(isWideLayout: isWideLayout), spacing: 10) {
                    ForEach(filteredServers) { server in
                        NavigationLink {
                            ServerDetailView(server: server, themeStore: themeStore)
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
                    if dashboardViewModel.loadingState == .loaded {
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(isServerOnline(timestamp: server.lastActive) || server.status.uptime == 0 ? .red : .green)
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
                .tint(themeStore.themeTintColor(scheme: scheme))
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
            Button {
                UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
            } label: {
                Label("Copy IPv4", systemImage: "4.circle")
            }
            Button {
                UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
            } label: {
                Label("Copy IPv6", systemImage: "6.circle")
            }
        }))
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
