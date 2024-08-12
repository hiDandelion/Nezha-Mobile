//
//  DashboardDetailView.swift
//  Watch App Watch App
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct DashboardDetailView: View {
    var dashboardLink: String
    var dashboardAPIToken: String
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var servers: [(key: Int, value: Server)] = []
    @State private var isShowingSettingSheet: Bool = false
    @State private var newSettingRequireReconnection: Bool? = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch(dashboardViewModel.loadingState) {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .loaded:
                    if dashboardViewModel.servers.isEmpty {
                        ProgressView()
                    }
                    else {
                        ScrollView {
                            let servers = dashboardViewModel.servers.sorted {
                                if $0.displayIndex == nil || $0.displayIndex == nil {
                                    return $0.id < $1.id
                                }
                                else {
                                    if $0.displayIndex == $1.displayIndex {
                                        return $0.id < $1.id
                                    }
                                    else {
                                        return $0.displayIndex! > $1.displayIndex!
                                    }
                                }
                            }
                            
                            ForEach(servers, id: \.id) { server in
                                NavigationLink(destination: ServerDetailView(server: server)) {
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
                                        Text(server.name)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Dashboard")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    isShowingSettingSheet = true
                                } label: {
                                    Label("Settings", systemImage: "gear")
                                }
                            }
                        }
                    }
                case .error(let message):
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 5) {
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
}
