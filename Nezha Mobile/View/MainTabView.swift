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

@Observable
class TabBarState {
    var isShowTabBar: Bool = true
    var activeTab: MainTab = .home
}

struct MainTabView: View {
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    var dashboardLink: String
    var dashboardAPIToken: String
    var dashboardViewModel: DashboardViewModel
    @State private var isDefaultTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if #available(iOS 18, *) {
                    TabView(selection: Bindable(tabBarState).activeTab) {
                        Tab.init(value: MainTab.home) {
                            ServerListView(dashboardViewModel: dashboardViewModel)
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
                            SettingsView(dashboardViewModel: dashboardViewModel)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                } else {
                    TabView(selection: Bindable(tabBarState).activeTab) {
                        ServerListView(dashboardViewModel: dashboardViewModel)
                            .tag(MainTab.home)
                            .overlay {
                                if !isDefaultTabBarHidden {
                                    HideTabBar {
                                        isDefaultTabBarHidden = true
                                    }
                                }
                            }
                        
                        ServerMapView(servers: dashboardViewModel.servers)
                            .tag(MainTab.map)
                        
                        AlertListView()
                            .tag(MainTab.alerts)
                        
                        SettingsView(dashboardViewModel: dashboardViewModel)
                            .tag(MainTab.settings)
                    }
                }
            }
            
            MainTabBar(activeTab: Bindable(tabBarState).activeTab)
                .opacity(tabBarState.isShowTabBar ? 1 : 0)
        }
    }
}

struct MainTabBar: View {
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

struct HideTabBar: UIViewRepresentable {
    init(result: @escaping () -> Void) {
        UITabBar.appearance().isHidden = true
        self.result = result
    }
    
    var result: () -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let tabController = view.tabController {
                UITabBar.appearance().isHidden = false
                tabController.tabBar.isHidden = true
                result()
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {  }
}

extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: {
            $0.next
        }).first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }
        
        return nil
    }
}
