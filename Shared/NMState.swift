//
//  NMState.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/25/24.
//

import Foundation
import SwiftUI
import Combine
import Observation
import BackgroundTasks

@Observable
class NMState {
    var pathServers: NavigationPath = .init()
    var pathTools: NavigationPath = .init()
    var pathAlerts: NavigationPath = .init()
    var pathSettings: NavigationPath = .init()
    
#if os(iOS) || os(visionOS)
    var tab: MainTab = .servers
    var isShowMapView: Bool = false
#endif
    
#if os(macOS)
    var incomingAlert: (title: String, body: String)?
#endif
    
    var dashboardLoadingState: LoadingState = .idle
    var dashboardLastUpdateTime: Date?
    var servers: [ServerData] = .init()
    var serverGroups: [ServerGroup] = .init()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var serviceLoadingState: LoadingState = .idle
    var services: [ServiceData] = .init()
    
    var notificationLoadingState: LoadingState = .idle
    var notifications: [NotificationData] = .init()
    var alertRules: [AlertRuleData] = .init()
    
    func loadDashboard() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            dashboardLoadingState = .error("Dashboard is not properly configured.")
            return
        }
        
        dashboardLoadingState = .loading
        
        Task {
            do {
                try await getServer()
                try await getServerGroup()
                dashboardLoadingState = .loaded
                dashboardLastUpdateTime = Date()
            }
            catch {
                withAnimation {
                    dashboardLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task {
                try? await self?.getServer()
            }
        }
    }
    
    func loadServices() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            serviceLoadingState = .error("Dashboard is not properly configured.")
            return
        }
        
        serviceLoadingState = .loading
        
        Task {
            do {
                try await getServices()
                serviceLoadingState = .loaded
            }
            catch {
                withAnimation {
                    serviceLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }
    
    func loadNotifications() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            notificationLoadingState = .error("Dashboard is not properly configured.")
            return
        }
        
        notificationLoadingState = .loading
        
        Task {
            do {
                try await getNotification()
                try await getAlertRule()
                notificationLoadingState = .loaded
            }
            catch {
                withAnimation {
                    notificationLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }
    
    // MARK: -
    func refreshServerGroup() async {
        try? await getServerGroup()
    }
    
    func refreshServerAndServerGroup() async {
        try? await getServer()
        try? await getServerGroup()
    }
    
    func refreshServices() async {
        try? await getServices()
    }
    
    func refreshNotifications() async {
        try? await getNotification()
    }
    
    func refreshAlertRules() async {
        try? await getAlertRule()
    }
    
    // MARK: -
    private func getServer() async throws {
        let response = try await RequestHandler.getServer()
        withAnimation {
            servers = response.data?.map({
                ServerData(
                    serverID: $0.id,
                    name: $0.name,
                    displayIndex: $0.display_index,
                    lastActive: $0.last_active,
                    ipv4: $0.geoip?.ip?.ipv4_addr ?? "",
                    ipv6: $0.geoip?.ip?.ipv6_addr ?? "",
                    countryCode: $0.geoip?.country_code ?? "",
                    host: ServerData.Host(
                        platform: $0.host.platform ?? "",
                        platformVersion: $0.host.platform_version ?? "",
                        cpu: $0.host.cpu ?? [""],
                        memoryTotal: $0.host.mem_total ?? 0,
                        swapTotal: $0.host.swap_total ?? 0,
                        diskTotal: $0.host.disk_total ?? 0,
                        architecture: $0.host.arch ?? "",
                        virtualization: $0.host.virtualization ?? "",
                        bootTime: $0.host.boot_time ?? 0
                    ),
                    status: ServerData.Status(
                        cpuUsed: $0.state.cpu ?? 0,
                        memoryUsed: $0.state.mem_used ?? 0,
                        swapUsed: $0.state.swap_used ?? 0,
                        diskUsed: $0.state.disk_used ?? 0,
                        networkIn: $0.state.net_in_transfer ?? 0,
                        networkOut: $0.state.net_out_transfer ?? 0,
                        networkInSpeed: $0.state.net_in_speed ?? 0,
                        networkOutSpeed: $0.state.net_out_speed ?? 0,
                        uptime: $0.state.uptime ?? 0,
                        load1: $0.state.load_1 ?? 0,
                        load5: $0.state.load_5 ?? 0,
                        load15: $0.state.load_15 ?? 0,
                        tcpConnectionCount: $0.state.tcp_conn_count ?? 0,
                        udpConnectionCount: $0.state.udp_conn_count ?? 0,
                        processCount: $0.state.process_count ?? 0
                    )
                )
            }) ?? []
        }
    }
    
    private func getServerGroup() async throws {
        let response = try await RequestHandler.getServerGroup()
        withAnimation {
            serverGroups = response.data?.map({
                ServerGroup(
                    serverGroupID: $0.group.id,
                    name: $0.group.name,
                    serverIDs: $0.servers ?? .init()
                )
            }) ?? []
        }
    }
    
    private func getServices() async throws {
        let response = try await RequestHandler.getService()
        withAnimation {
            services = response.data?.map({
                ServiceData(
                    serviceID: $0.id,
                    notificationGroupID: $0.notification_group_id ?? 0,
                    name: $0.name ?? "",
                    type: ServiceType(rawValue: $0.type ?? 0) ?? .get,
                    target: $0.target ?? "",
                    interval: $0.duration ?? 0,
                    minimumLatency: $0.min_latency ?? 0,
                    maximumLatency: $0.max_latency ?? 0,
                    coverageOption: $0.cover ?? 0,
                    excludeRule: $0.skip_servers,
                    failureTaskIDs: $0.fail_trigger_tasks,
                    recoverTaskIDs: $0.recover_trigger_tasks
                )
            }) ?? []
        }
    }
    
    private func getNotification() async throws {
        let response = try await RequestHandler.getNotification()
        withAnimation {
            self.notifications = response.data?.map({
                NotificationData(
                    notificationID: $0.id,
                    name: $0.name,
                    url: $0.url,
                    requestMethod: $0.request_method,
                    requestType: $0.request_type,
                    requestHeader: $0.request_header,
                    requestBody: $0.request_body,
                    isVerifyTLS: $0.verify_tls
                )
            }) ?? []
        }
    }
    
    private func getAlertRule() async throws {
        let response = try await RequestHandler.getAlertRule()
        withAnimation {
            alertRules = response.data?.map({ alertRule in
                AlertRuleData(
                    alertRuleID: alertRule.id,
                    notificationGroupID: alertRule.notification_group_id,
                    name: alertRule.name,
                    isEnabled: alertRule.enable,
                    triggerOption: alertRule.trigger_mode,
                    triggerRule: alertRule.rules,
                    failureTaskIDs: alertRule.fail_trigger_tasks,
                    recoverTaskIDs: alertRule.recover_trigger_tasks
                )
            }) ?? []
        }
    }
}
