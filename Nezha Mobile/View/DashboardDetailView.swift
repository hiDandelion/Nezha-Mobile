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
    @FocusState private var isSearching: Bool
    @State private var searchText: String = ""
    @State private var activeTag: String = String(localized: "All")
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    @Namespace private var animation
    
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
                            ScrollView {
                                ExpandableNavigationBar(isLoading: dashboardViewModel.loadingState == .loading)
                                    .zIndex(1)
                                    .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
                                serverList
                                    .zIndex(0)
                            }
                            .contentMargins(.top, 165, for: .scrollIndicators)
                            .toolbar(.hidden, for: .navigationBar)
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
            if dashboardLink != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
    
    @ViewBuilder
    func ExpandableNavigationBar(title: String = "Dashboard", isLoading: Bool = false) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let scrollviewHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
            let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollviewHeight, 1), 0) * 0.5) : 1
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            
            VStack(spacing: 10 - (progress * 10)) {
                /// Title
                HStack {
                    HStack {
                        Text(title)
                            .font(.largeTitle.bold())
                            .scaleEffect(scaleProgress, anchor: .topLeading)
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
                
                /// Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    
                    TextField("Search Server", text: $searchText)
                        .focused($isSearching)
                    
                    if isSearching {
                        Button(action: {
                            isSearching = false
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
                
                /// Segmented Picker
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        if !dashboardViewModel.servers.isEmpty {
                            let tags = Array(Set(dashboardViewModel.servers.map { $0.tag }))
                            let allTags = [String(localized: "All")] + tags.sorted()
                            ForEach(allTags, id: \.self) { tag in
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
                        }
                    }
                }
                .frame(height: 40)
                .scrollIndicators(.never)
            }
            .padding(.top, 15)
            .safeAreaPadding(.horizontal, 15)
            .offset(y: minY < 0 || isSearching ? -minY : 0)
            .offset(y: -progress * 65)
        }
        .frame(height: 155)
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
    
    private var serverList: some View {
        VStack {
            if !dashboardViewModel.servers.isEmpty {
                let servers = dashboardViewModel.servers.sorted { (($0.displayIndex ?? -1) == ($1.displayIndex ?? -1)) ? ($0.id < $1.id) : (($0.displayIndex ?? -1) > ($1.displayIndex ?? -1)) }
                let taggedServers = servers.filter { activeTag == String(localized: "All") || $0.tag == activeTag }
                let seachedServers = taggedServers.filter { searchText == "" || $0.name.contains(searchText) }
                ForEach(seachedServers, id: \.id) { server in
                    NavigationLink(destination: ServerDetailView(server: server)) {
                        serverCard(server: server)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .safeAreaPadding(.horizontal, 15)
                }
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
    
    func serverCard(server: Server) -> some View {
        CardView {
            HStack {
                Text(countryFlagEmoji(countryCode: server.host.countryCode))
                Text(server.name)
                Image(systemName: "circlebadge.fill")
                    .foregroundStyle(server.status.cpu != 0 || server.status.memUsed != 0 ? .green : .red)
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
                                Image(systemName: "power")
                                    .frame(width: 10)
                                Text("\(formatTimeInterval(seconds: server.status.uptime))")
                            }
                            
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
                
                HStack {
                    let totalCore = getCore(server.host.cpu).toDouble()
                    let loadPressure = server.status.load1 / (totalCore ?? 1.0)
                    
                    Text("Load \(server.status.load1, specifier: "%.2f")")
                        .font(.caption2)
                    
                    Gauge(value: loadPressure <= 1 ? loadPressure : 1) {
                        
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                }
                .padding(.horizontal)
            }
        }
    }
}
