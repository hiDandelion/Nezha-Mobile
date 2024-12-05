//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Servers", systemImage: "server.rack") {
                ServerListView()
            }
            
            Tab("Tools", systemImage: "briefcase") {
                ToolListView()
            }
            
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
