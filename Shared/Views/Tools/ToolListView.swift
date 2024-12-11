//
//  ToolListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
//

import SwiftUI

struct ToolListView: View {
#if os(iOS)
    @Environment(TabBarState.self) var tabBarState
#endif
    
    var body: some View {
        NavigationStack {
            List {
                Section("Dashboard") {
                    NavigationLink {
                        ServerGroupListView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "Server Groups", systemName: "square.grid.3x2", color: .blue)
                    }
                    
                    NavigationLink {
                        ServiceListView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "Monitors", systemName: "chart.xyaxis.line", color: .purple)
                    }
                    
                    NavigationLink {
                        NotificationView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "Notifications", systemName: "bell.badge", color: .red)
                    }
                }
                
                Section("Agent") {
                    NavigationLink {
                        DeviceInfoView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "View Device Info", systemName: "info.circle", color: .blue)
                    }
                }
            }
            .navigationTitle("Tools")
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
#if os(iOS)
            .onAppear {
                withAnimation {
                    tabBarState.isToolsViewVisible = true
                }
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isToolsViewVisible = false
                }
            }
#endif
        }
    }
}
