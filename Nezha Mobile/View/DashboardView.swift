//
//  DashboardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
//

import SwiftUI

struct DashboardView: View {
    var dashboardLink: String
    var dashboardAPIToken: String
    var dashboardViewModel: DashboardViewModel
    var themeStore: ThemeStore
    @State private var isShowingServerMapView: Bool = false
    
    var body: some View {
        VStack {
            if isShowingServerMapView {
                ServerMapView(isShowingServerMapView: $isShowingServerMapView, servers: dashboardViewModel.servers)
            }
            else {
                ServerListView(dashboardViewModel: dashboardViewModel, themeStore: themeStore, isShowingServerMapView: $isShowingServerMapView)
            }
        }
        .onAppear {
            // Start monitoring
            if dashboardLink != "" && dashboardAPIToken != "" && !dashboardViewModel.isMonitoringEnabled {
                dashboardViewModel.startMonitoring()
            }
        }
    }
}
