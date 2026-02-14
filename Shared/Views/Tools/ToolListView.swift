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
        NavigationStack(path: Bindable(state).pathTools) {
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

                    NavigationLink(value: "cron-list") {
                        TextWithColorfulIcon(titleKey: "Tasks", systemName: "clock.arrow.2.circlepath", color: .green)
                    }

                    NavigationLink(value: "ddns-list") {
                        TextWithColorfulIcon(titleKey: "DDNS", systemName: "network.badge.shield.half.filled", color: .cyan)
                    }

                    NavigationLink(value: "nat-list") {
                        TextWithColorfulIcon(titleKey: "NAT", systemName: "arrow.left.arrow.right", color: .teal)
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
                case "snippet-list":
                    SnippetListView(executeAction: nil)
                case "cron-list":
                    CronListView()
                case "ddns-list":
                    DDNSListView()
                case "nat-list":
                    NATListView()
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
            .navigationDestination(for: NATData.self) { nat in
                NATDetailView(natID: nat.natID)
            }
            .navigationDestination(for: NotificationGroupData.self) { notificationGroup in
                NotificationGroupDetailView(notificationGroupID: notificationGroup.notificationGroupID)
            }
            .navigationDestination(for: CronData.self) { cron in
                CronDetailView(cronID: cron.cronID)
            }
            .navigationDestination(for: DDNSData.self) { ddns in
                DDNSDetailView(ddnsID: ddns.ddnsID)
            }
            .navigationDestination(for: AlertRuleData.self) { alertRule in
                AlertRuleDetailView(alertRuleID: alertRule.alertRuleID)
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
