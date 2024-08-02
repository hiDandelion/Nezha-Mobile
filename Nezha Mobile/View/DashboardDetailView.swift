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
    @Bindable var dashboard: Dashboard
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @AppStorage("bgColor") private var bgColor = "blue"
    @State private var isShowingSettingView: Bool = false
    
    var body: some View {
        let connectionURLString: String = "\(dashboard.ssl ? "wss" : "ws")://\(dashboard.link)/ws"
        
        NavigationStack {
            VStack {
                switch(dashboardViewModel.loadingState) {
                case .idle:
                    Text("Preparing...")
                case .loading:
                    ProgressView("Loading...")
                case .loaded:
                    ZStack {
                        backgroundGradient(color: bgColor)
                            .ignoresSafeArea()
                        ZStack(alignment: .bottomTrailing) {
                            if isShowingSettingView {
                                SettingView(dashboardViewModel: dashboardViewModel)
                            }
                            else {
                                serverList
                            }
                            
                            Button {
                                withAnimation {
                                    isShowingSettingView.toggle()
                                }
                            } label: {
                                Image(systemName: isShowingSettingView ? "chevron.left" : "gear")
                                    .font(.title.weight(.semibold))
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4, x: 0, y: 4)
                                
                            }
                            .padding()
                        }
                    }
                case .error(let message):
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 10) {
                            Text("An error occured")
                                .font(.headline)
                            Text(message)
                                .font(.subheadline)
                            Button("Retry") {
                                dashboardViewModel.connect(to: connectionURLString)
                            }
                            Button("Settings") {
                                isShowingSettingView.toggle()
                            }
                            .sheet(isPresented: $isShowingSettingView) {
                                SettingView(dashboardViewModel: dashboardViewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar(.hidden)
        }
        .onAppear {
            dashboardViewModel.connect(to: connectionURLString)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                print("Scene Phase became active")
                dashboardViewModel.connect(to: connectionURLString)
            }
            if scenePhase == .background {
                dashboardViewModel.disconnect()
            }
        }
    }
    
    private var serverList: some View {
        ScrollView {
            if let servers = dashboardViewModel.socketResponse?.servers {
                ForEach(servers, id: \.id) { server in
                    NavigationLink(destination: ServerDetailView(dashboard: dashboard, dashboardViewModel: dashboardViewModel, serverId: server.id)) {
                        CustomStackView {
                            HStack {
                                Text(countryFlagEmoji(countryCode: server.host.countryCode))
                                Text(server.name)
                            }
                        } contentView: {
                            HStack {
                                HStack {
                                    let cpuUsage = server.state.cpu / 100
                                    let memUsage = (server.host.memTotal == 0 ? 0 : Double(server.state.memUsed) / Double(server.host.memTotal))
                                    let diskUsage = (server.host.diskTotal == 0 ? 0 : Double(server.state.diskUsed) / Double(server.host.diskTotal))
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
                                    
                                    HStack {
                                        Image(systemName: "network")
                                        VStack(alignment: .leading) {
                                            Text("↑\(formatBytes(server.state.netOutTransfer))")
                                            Text("↓\(formatBytes(server.state.netInTransfer))")
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                                .font(.caption2)
                                .frame(width: 100)
                                .padding(.leading, 10)
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
    }
}
