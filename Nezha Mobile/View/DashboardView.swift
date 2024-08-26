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
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var themeStore: ThemeStore
    @State private var isShowingServerMapView: Bool = false
    
    var body: some View {
        VStack {
            if isShowingServerMapView {
                if #available(iOS 17.0, *) {
                    ServerMapView(isShowingServerMapView: $isShowingServerMapView, servers: dashboardViewModel.servers)
                } else {
                    // ServerMapView ×
                    EmptyView()
                }
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
