//
//  MainTabView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case servers = "servers"
    case tools = "tools"
    case alerts = "alerts"
    case settings = "settings"
    
    var systemName: String {
        switch self {
        case .servers: "server.rack"
        case .tools: "briefcase"
        case .alerts: "bell"
        case .settings: "gearshape"
        }
    }
    
    var title: String {
        switch self {
        case .servers: String(localized: "Servers")
        case .tools: String(localized: "Tools")
        case .alerts: String(localized: "Alerts")
        case .settings: String(localized: "Settings")
        }
    }
}

struct MainTabView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    @State private var isDefaultTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if #available(iOS 18, *) {
                    TabView(selection: Bindable(state).tab) {
                        Tab(value: MainTab.servers) {
                            if state.isShowMapView {
                                ServerMapView()
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                            else {
                                ServerListView()
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                        }
                        
                        Tab(value: MainTab.tools) {
                            ToolListView()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab(value: MainTab.alerts) {
                            AlertListView()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                        
                        Tab(value: MainTab.settings) {
                            SettingsView()
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                } else {
                    TabView(selection: Bindable(state).tab) {
                        if state.isShowMapView {
                            ServerMapView()
                                .tag(MainTab.servers)
                        }
                        else {
                            ServerListView()
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
                        
                        SettingsView()
                            .tag(MainTab.settings)
                    }
                }
            }
            
            MainTabBar(activeBackground: theme.themeTintColor(scheme: scheme), activeTab: Bindable(state).tab)
                .opacity(state.path.isEmpty && !state.isShowMapView ? 1 : 0)
                .animation(.easeInOut, value: state.path.count)
        }
    }
}

struct MainTabBar: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NMState.self) var state
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
                            Image(systemName: tab.systemName)
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
            .if(scheme == .light, transform: { view in
                view.background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                        .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
                )
            })
            .if(scheme == .dark, transform: { view in
                view.background(
                    Capsule()
                        .fill(.black)
                        .strokeBorder(Color(red: 41/255, green: 41/255, blue: 41/255), lineWidth: 2)
                )
            })
            .zIndex(10)
            
            Button {
                if activeTab == .servers {
                    withAnimation {
                        state.isShowMapView = true
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
