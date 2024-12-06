//
//  ContentView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        VStack {
            if dashboardLink == "" || dashboardUsername == "" || isShowingAddDashboardSheet {
                VStack {
                    Text("Start your journey with Nezha Mobile")
                        .font(.title3)
                        .frame(alignment: .center)
                    Button("Start", systemImage: "arrow.right.circle") {
                        isShowingAddDashboardSheet = true
                    }
                    .font(.headline)
                    .padding(.top, 20)
                    .sheet(isPresented: $isShowingAddDashboardSheet) {
                        AddDashboardView(dashboardViewModel: dashboardViewModel)
                    }
                }
                .padding()
            }
            else {
                ServerListView(dashboardViewModel: dashboardViewModel)
                    .onAppear {
                        if dashboardLink != "" && dashboardUsername != "" && !dashboardViewModel.isMonitoringEnabled {
                            dashboardViewModel.startMonitoring()
                        }
                    }
            }
        }
        .onAppear {
            NMCore.syncWithiCloud()
        }
    }
}
