//
//  ContentView.swift
//  Nezha Vision
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct ContentView: View {
    var dashboardViewModel: DashboardViewModel
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        Group {
            if dashboardLink == "" || dashboardUsername == "" || isShowingAddDashboardSheet {
                dashboardUnconfigured
            }
            else {
                dashboardConfigured
            }
        }
    }
    
    private var dashboardUnconfigured: some View {
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
    
    private var dashboardConfigured: some View {
        MainTabView(dashboardViewModel: dashboardViewModel)
            .onAppear {
                if dashboardLink != "" && dashboardUsername != "" && !dashboardViewModel.isMonitoringEnabled {
                    dashboardViewModel.startMonitoring()
                }
            }
    }
}
