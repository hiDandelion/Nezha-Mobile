//
//  ContentView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(ThemeStore.self) var themeStore
    var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @AppStorage("NMDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardAPIToken: String = ""
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        Group {
            if dashboardLink == "" || dashboardAPIToken == "" || isShowingAddDashboardSheet {
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
                MainTabView(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardViewModel: dashboardViewModel)
                    .onAppear {
                        // Start monitoring
                        if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                            dashboardViewModel.startMonitoring()
                        }
                    }
            }
        }
    }
}
