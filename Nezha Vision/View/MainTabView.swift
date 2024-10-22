//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct MainTabView: View {
    var dashboardViewModel: DashboardViewModel
    var dashboardLink: String
    var dashboardAPIToken: String
    
    var body: some View {
        TabView {
            Tab("Servers", systemImage: "server.rack") {
                ServerListView(dashboardViewModel: dashboardViewModel)
            }
            
            Tab("Settings", systemImage: "gearshape") {
                SettingsView(dashboardViewModel: dashboardViewModel)
            }
        }
    }
}
