//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case home = "house"
    case map = "map"
    case alerts = "bell"
    case settings = "gearshape"
    
    var title: String {
        switch self {
        case .home: String(localized: "Home")
        case .map: String(localized: "Map")
        case .alerts: String(localized: "Alerts")
        case .settings: String(localized: "Settings")
        }
    }
}

struct MainTabView: View {
    var dashboardLink: String
    var dashboardAPIToken: String
    var dashboardViewModel: DashboardViewModel
    var themeStore: ThemeStore
    @State private var activeTab: MainTab = .home
    @State private var isTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if #available(iOS 18, *) {
                    TabView(selection: $activeTab) {
                        Tab.init(value: MainTab.home) {
                                ServerListView(dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                                    .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: MainTab.map) {
                            ServerMapView(servers: dashboardViewModel.servers)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: MainTab.alerts) {
                            AlertListView()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab.init(value: MainTab.settings) {
                            SettingView(dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                } else {
                    TabView(selection: $activeTab) {
                        ServerListView(dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                            .tag(MainTab.home)
                        
                        ServerMapView(servers: dashboardViewModel.servers)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.primary.opacity(0.07))
                            .tag(MainTab.map)
                        
                        AlertListView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.primary.opacity(0.07))
                            .tag(MainTab.alerts)
                        
                        SettingView(dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.primary.opacity(0.07))
                            .tag(MainTab.settings)
                    }
                }
            }
            
            CustomTabBar(activeTab: $activeTab)
        }
    }
}

struct CustomTabBar: View {
    var activeForeground: Color = .white
    var activeBackground: Color = .blue
    @Binding var activeTab: MainTab
    @Namespace private var animation
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    activeTab = tab
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.rawValue)
                            .font(.title3)
                            .frame(width: 30, height: 30)
                        
                        if activeTab == tab {
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(activeTab == tab ? activeForeground : .gray)
                    .padding(.vertical, 2)
                    .padding(.leading, 10)
                    .padding(.trailing, 15)
                    .contentShape(.rect)
                    .background {
                        if activeTab == tab {
                            Capsule()
                                .fill(.clear)
                                .onGeometryChange(for: CGRect.self, of: {
                                    $0.frame(in: .named("TABBARVIEW"))
                                }, action: { newValue in
                                    tabLocation = newValue
                                })
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(alignment: .leading) {
            Capsule()
                .fill(activeBackground.gradient)
                .frame(width: tabLocation.width, height: tabLocation.height)
                .offset(x: tabLocation.minX)
        }
        .coordinateSpace(.named("TABBARVIEW"))
        .padding(.horizontal, 5)
        .frame(height: 45)
        .background(
            .background
                .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                .shadow(.drop(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)),
            in: .capsule
        )
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
        .frame(maxWidth: .infinity)
    }
}
