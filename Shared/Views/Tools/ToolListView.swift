//
//  ToolListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
//

import SwiftUI
import NezhaMobileData

struct ToolListView: View {
    @Environment(NMState.self) var state
    
    var body: some View {
        NavigationStack(path: Bindable(state).path) {
            List {
                Section("Dashboard") {
                    NavigationLink(value: "server-group-list") {
                        TextWithColorfulIcon(titleKey: "Server Groups", systemName: "square.grid.3x2", color: .blue)
                    }
                    
                    NavigationLink(value: "service-list") {
                        TextWithColorfulIcon(titleKey: "Monitors", systemName: "chart.xyaxis.line", color: .purple)
                    }
                    
                    NavigationLink(value: "notification-list") {
                        TextWithColorfulIcon(titleKey: "Notifications", systemName: "bell.badge", color: .red)
                    }
                }
                
                Section("Agent") {
                    NavigationLink(value: "device-info") {
                        TextWithColorfulIcon(titleKey: "View Device Info", systemName: "info.circle", color: .blue)
                    }
                }
                
                Section("Terminal") {
                    NavigationLink(value: "snippet-list") {
                        TextWithColorfulIcon(titleKey: "Snippets", systemName: "text.page", color: .orange)
                    }
                }
            }
            .navigationTitle("Tools")
            .navigationDestination(for: String.self) { target in
                switch target {
                case "server-group-list":
                    ServerGroupListView()
                case "service-list":
                    ServiceListView()
                case "notification-list":
                    NotificationListView()
                case "device-info":
                    DeviceInfoView()
                case "snippet-list":
                    SnippetListView(executeAction: nil)
                default:
                    EmptyView()
                }
            }
            .navigationDestination(for: ServerGroup.self) { serverGroup in
                ServerGroupDetailView(serverGroupID: serverGroup.serverGroupID)
            }
            .navigationDestination(for: ServiceData.self) { service in
                ServiceDetailView(service: service)
            }
            .navigationDestination(for: TerminalSnippet.self) { terminalSnippet in
                SnippetDetailView(terminalSnippet: terminalSnippet)
            }
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
        }
    }
}
