//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case servers = "server.rack"
    case tools = "wrench.and.screwdriver"
    case alerts = "bell"
    case settings = "gearshape"
    
    var title: String {
        switch self {
        case .servers: String(localized: "Servers")
        case .tools: String(localized: "Tools")
        case .alerts: String(localized: "Alerts")
        case .settings: String(localized: "Settings")
        }
    }
}

@Observable
class TabBarState {
    var isTabBarHidden: Bool = false
    var activeTab: MainTab = .servers
    
    var isShowMapView: Bool = false
    
    var isServersViewVisible: Bool = false
    var isToolsViewVisible: Bool = false
    var isAlertsViewVisible: Bool = false
    var isSettingsViewVisible: Bool = false
    
    var shouldMakeTabBarVisible: Bool {
        !isTabBarHidden && (isServersViewVisible || isToolsViewVisible || isAlertsViewVisible || isSettingsViewVisible)
    }
}

struct MainTabView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    @AppStorage("NMTheme", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var theme: NMTheme = .blue
    var dashboardLink: String
    var dashboardAPIToken: String
    var dashboardViewModel: DashboardViewModel
    @State private var isDefaultTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if #available(iOS 18, *) {
                    TabView(selection: Bindable(tabBarState).activeTab) {
                        Tab.init(value: MainTab.servers) {
                            if tabBarState.isShowMapView {
                                ServerMapView(servers: dashboardViewModel.servers)
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                            else {
                                ServerListView(dashboardViewModel: dashboardViewModel)
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                        }
                        
                        Tab.init(value: MainTab.tools) {
                            ToolListView()
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
                        if tabBarState.isShowMapView {
                            ServerMapView(servers: dashboardViewModel.servers)
                                .tag(MainTab.servers)
                        }
                        else {
                            ServerListView(dashboardViewModel: dashboardViewModel)
                                .tag(MainTab.servers)
                                .overlay {
                                    if !isDefaultTabBarHidden {
                                        HideTabBar {
                                            isDefaultTabBarHidden = true
                                        }
                                    }
                                }
                        }
                        
                        ToolListView()
                            .tag(MainTab.tools)
                        
                        AlertListView()
                            .tag(MainTab.alerts)
                        
                        SettingsView(dashboardViewModel: dashboardViewModel)
                            .tag(MainTab.settings)
                    }
                }
            }
            
            if themeStore.themeCustomizationEnabled {
                MainTabBar(activeForeground: themeStore.themePrimaryColor(scheme: scheme), activeBackground: themeStore.themeTintColor(scheme: scheme), activeTab: Bindable(tabBarState).activeTab)
                    .opacity(tabBarState.shouldMakeTabBarVisible ? 1 : 0)
            }
            else {
                MainTabBar(activeBackground: themeColor(theme: theme), activeTab: Bindable(tabBarState).activeTab)
                    .opacity(tabBarState.shouldMakeTabBarVisible ? 1 : 0)
            }
        }
    }
}

struct MainTabBar: View {
    @Environment(TabBarState.self) var tabBarState
    var activeForeground: Color = .white
    var activeBackground: Color = .blue
    @Binding var activeTab: MainTab
    @Namespace private var animation
    @State private var tabLocation: CGRect = .zero
    
    var body: some View {
        let status = activeTab == .servers
        
        HStack(spacing: !status ? 0 : 12) {
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
            .zIndex(10)
            
            Button {
                if activeTab == .servers {
                    withAnimation {
                        tabBarState.isShowMapView = true
                    }
                }
            } label: {
                MorphingSymbolView(
                    symbol: "map",
                    config: .init(
                        font: .title3,
                        frame: .init(width: 42, height: 42),
                        radius: 5,
                        foregroundColor: activeForeground,
                        keyFrameDuration: 0.3,
                        symbolAnimation: .smooth(duration: 0.35, extraBounce: 0)
                    )
                )
                .background(activeBackground.gradient)
                .clipShape(.circle)
            }
            .allowsHitTesting(status)
            .offset(x: status ? 0 : -20)
            .padding(.leading, status ? 0 : -42)
            .opacity(status ? 1 : 0)
        }
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
