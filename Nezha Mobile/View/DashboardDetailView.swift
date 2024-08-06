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
    var dashboardLink: String
    var dashboardAPIToken: String
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var servers: [(key: Int, value: Server)] = []
    @AppStorage("bgColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var bgColor = "blue"
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation {
        didSet {
            if DynamicIsland.isAvailable && orientation == .portrait {
                activateDynamicIslandIndicator()
            }
            else {
                deactivateDynamicIslandIndicator()
            }
        }
    }
    @State private var showDynamicIslandProgressIndicator: Bool = false
    @State private var scrollViewHeight: CGFloat = 0
    @State private var scrollPercentage: CGFloat = 0 {
        didSet {
            if showDynamicIslandProgressIndicator {
                DynamicIsland.progressIndicator.progress = scrollPercentage * 100
            }
        }
    }
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch(dashboardViewModel.loadingState) {
                case .idle:
                    ZStack {
                        backgroundGradient(color: bgColor)
                            .ignoresSafeArea()
                    }
                case .loading:
                    ZStack {
                        backgroundGradient(color: bgColor)
                            .ignoresSafeArea()
                        
                        ProgressView("Loading...")
                    }
                case .loaded:
                    ZStack {
                        backgroundGradient(color: bgColor)
                            .ignoresSafeArea()
                        
                        serverList
                            .toolbar {
                                ToolbarItem {
                                    Button("Settings", systemImage: "gear") {
                                        isShowingSettingSheet = true
                                    }
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
            activateDynamicIslandIndicator()
        }
        .onDisappear {
            deactivateDynamicIslandIndicator()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                activateDynamicIslandIndicator()
            }
            if scenePhase != .active {
                deactivateDynamicIslandIndicator()
            }
        }
        .onRotate { orientation in
            self.orientation = orientation
        }
    }
    
    private var serverList: some View {
        ScrollView {
            VStack {
                if true {
                    let servers = dashboardViewModel.servers.sorted { $0.displayIndex == $1.displayIndex ? ($0.id < $1.id) : ($0.displayIndex > $1.displayIndex) }
                    ForEach(servers, id: \.id) { server in
                        NavigationLink(destination: ServerDetailView(server: server)) {
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
                                                Text(getCore(server.host.cpu))
                                            }
                                            
                                            HStack {
                                                Image(systemName: "memorychip")
                                                Text("\(formatBytes(server.host.memTotal))")
                                            }
                                            
                                            HStack {
                                                Image(systemName: "internaldrive")
                                                Text("\(formatBytes(server.host.diskTotal))")
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Image(systemName: "power")
                                                    Text("\(formatTimeInterval(seconds: server.status.uptime))")
                                                }
                                                
                                                HStack {
                                                    Image(systemName: "network")
                                                    VStack(alignment: .leading) {
                                                        Text("↑\(formatBytes(server.status.netOutTransfer))")
                                                        Text("↓\(formatBytes(server.status.netInTransfer))")
                                                    }
                                                }
                                            }
                                            .padding(.top, 5)
                                        }
                                        .font(.caption2)
                                        .frame(width: 100)
                                        .padding(.leading, 10)
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
                                    .padding([.horizontal, .bottom])
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
                else {
                    ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
                }
            }
            .background(GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    let totalHeight = proxy.size.height
                    let screenHeight = UIScreen.main.bounds.size.height
                    let currentOffset = -proxy.frame(in: .named("scroll")).origin.y
                    scrollPercentage = min(max(currentOffset / (totalHeight - screenHeight), 0), 1)
                }
                return Color.clear
            })
        }
        .scrollIndicators(showDynamicIslandProgressIndicator ? .never : .automatic)
    }
    
    private func activateDynamicIslandIndicator() {
        if DynamicIsland.isAvailable && orientation == .portrait {
            withAnimation {
                showDynamicIslandProgressIndicator = true
                DynamicIsland.progressIndicator.progressColor = .systemBlue
                DynamicIsland.progressIndicator.isProgressIndeterminate = false
                DynamicIsland.progressIndicator.progress = scrollPercentage * 100
            }
        }
    }
    
    private func deactivateDynamicIslandIndicator() {
        if DynamicIsland.isAvailable {
            withAnimation {
                showDynamicIslandProgressIndicator = false
                DynamicIsland.progressIndicator.hideProgressIndicator()
            }
        }
    }
}
