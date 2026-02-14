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
    
#if os(iOS)
    var isShowToast: Bool = false
    var toastType: Toast = .defaultToast
#endif
    
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

    var natLoadingState: LoadingState = .idle
    var nats: [NATData] = .init()

    var notificationGroupLoadingState: LoadingState = .idle
    var notificationGroups: [NotificationGroupData] = .init()

    var cronLoadingState: LoadingState = .idle
    var crons: [CronData] = .init()

    var ddnsLoadingState: LoadingState = .idle
    var ddnsProfiles: [DDNSData] = .init()

    private var getServerTask: Task<Void, Error>?
    private var getServerGroupTask: Task<Void, Error>?
    private var getServicesTask: Task<Void, Error>?
    private var getNotificationTask: Task<Void, Error>?
    private var getAlertRuleTask: Task<Void, Error>?
    private var getNATTask: Task<Void, Error>?
    private var getNotificationGroupTask: Task<Void, Error>?
    private var getCronTask: Task<Void, Error>?
    private var getDDNSTask: Task<Void, Error>?
    
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

    func loadNATs() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            natLoadingState = .error("Dashboard is not properly configured.")
            return
        }

        natLoadingState = .loading

        Task {
            do {
                try await getNATs()
                natLoadingState = .loaded
            }
            catch {
                withAnimation {
                    natLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }

    func refreshNATs() async {
        try? await getNATs()
    }

    func loadNotificationGroups() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            notificationGroupLoadingState = .error("Dashboard is not properly configured.")
            return
        }

        notificationGroupLoadingState = .loading

        Task {
            do {
                try await getNotificationGroups()
                notificationGroupLoadingState = .loaded
            }
            catch {
                withAnimation {
                    notificationGroupLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }

    func refreshNotificationGroups() async {
        try? await getNotificationGroups()
    }

    func loadCrons() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            cronLoadingState = .error("Dashboard is not properly configured.")
            return
        }

        cronLoadingState = .loading

        Task {
            do {
                try await getCrons()
                cronLoadingState = .loaded
            }
            catch {
                withAnimation {
                    cronLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }

    func refreshCrons() async {
        try? await getCrons()
    }

    func loadDDNS() {
        guard NMCore.getNezhaDashboardLink() != "",
              NMCore.getNezhaDashboardUsername() != "",
              NMCore.getNezhaDashboardPassword() != ""
        else {
            ddnsLoadingState = .error("Dashboard is not properly configured.")
            return
        }

        ddnsLoadingState = .loading

        Task {
            do {
                try await getDDNSProfiles()
                ddnsLoadingState = .loaded
            }
            catch {
                withAnimation {
                    ddnsLoadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }

    func refreshDDNS() async {
        try? await getDDNSProfiles()
    }

    // MARK: - Private Methods with Race Condition Prevention
    
    private func getServer() async throws {
        getServerTask?.cancel()
        
        getServerTask = Task {
            do {
                let response = try await RequestHandler.getServer()
                
                guard !Task.isCancelled else { return }
                
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
            } catch {
                throw error
            }
        }
        
        do {
            try await getServerTask?.value
        } catch {
            getServerTask = nil
            throw error
        }
    }
    
    private func getServerGroup() async throws {
        getServerGroupTask?.cancel()
        
        getServerGroupTask = Task {
            do {
                let response = try await RequestHandler.getServerGroup()
                
                guard !Task.isCancelled else { return }
                
                withAnimation {
                    serverGroups = response.data?.map({
                        ServerGroup(
                            serverGroupID: $0.group.id,
                            name: $0.group.name,
                            serverIDs: $0.servers ?? .init()
                        )
                    }) ?? []
                }
            } catch {
                throw error
            }
        }
        
        do {
            try await getServerGroupTask?.value
        } catch {
            getServerGroupTask = nil
            throw error
        }
    }
    
    private func getServices() async throws {
        getServicesTask?.cancel()
        
        getServicesTask = Task {
            do {
                let response = try await RequestHandler.getService()
                
                guard !Task.isCancelled else { return }
                
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
            } catch {
                throw error
            }
        }
        
        do {
            try await getServicesTask?.value
        } catch {
            getServicesTask = nil
            throw error
        }
    }
    
    private func getNotification() async throws {
        getNotificationTask?.cancel()
        
        getNotificationTask = Task {
            let response = try await RequestHandler.getNotification()
            
            guard !Task.isCancelled else { return }
            
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
        
        try await getNotificationTask?.value
    }
    
    private func getAlertRule() async throws {
        getAlertRuleTask?.cancel()
        
        getAlertRuleTask = Task {
            let response = try await RequestHandler.getAlertRule()
            
            guard !Task.isCancelled else { return }
            
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
        
        try await getAlertRuleTask?.value
    }

    private func getNATs() async throws {
        getNATTask?.cancel()

        getNATTask = Task {
            let response = try await RequestHandler.getNAT()

            guard !Task.isCancelled else { return }

            withAnimation {
                self.nats = response.data?.map({
                    NATData(
                        natID: $0.id,
                        name: $0.name,
                        serverID: $0.server_id,
                        host: $0.host ?? "",
                        domain: $0.domain ?? "",
                        isEnabled: $0.enabled ?? false
                    )
                }) ?? []
            }
        }

        try await getNATTask?.value
    }

    private func getNotificationGroups() async throws {
        getNotificationGroupTask?.cancel()

        getNotificationGroupTask = Task {
            let response = try await RequestHandler.getNotificationGroup()

            guard !Task.isCancelled else { return }

            withAnimation {
                self.notificationGroups = response.data?.map({
                    NotificationGroupData(
                        notificationGroupID: $0.group.id,
                        name: $0.group.name,
                        notificationIDs: $0.notifications ?? []
                    )
                }) ?? []
            }
        }

        try await getNotificationGroupTask?.value
    }

    private func getCrons() async throws {
        getCronTask?.cancel()

        getCronTask = Task {
            let response = try await RequestHandler.getCron()

            guard !Task.isCancelled else { return }

            withAnimation {
                self.crons = response.data?.map({
                    CronData(
                        cronID: $0.id,
                        name: $0.name ?? "",
                        taskType: CronTaskType(rawValue: $0.task_type ?? 0) ?? .scheduled,
                        scheduler: $0.scheduler ?? "",
                        command: $0.command ?? "",
                        coverageOption: $0.cover ?? 0,
                        serverIDs: $0.servers ?? [],
                        notificationGroupID: $0.notification_group_id ?? 0,
                        pushSuccessful: $0.push_successful ?? false,
                        lastExecutedAt: $0.last_executed_at ?? "",
                        lastResult: $0.last_result ?? false,
                        cronJobID: $0.cron_job_id ?? 0
                    )
                }) ?? []
            }
        }

        try await getCronTask?.value
    }

    private func getDDNSProfiles() async throws {
        getDDNSTask?.cancel()

        getDDNSTask = Task {
            let response = try await RequestHandler.getDDNS()

            guard !Task.isCancelled else { return }

            withAnimation {
                self.ddnsProfiles = response.data?.map({
                    DDNSData(
                        ddnsID: $0.id,
                        name: $0.name ?? "",
                        provider: $0.provider ?? "",
                        domains: $0.domains ?? [],
                        accessID: $0.access_id ?? "",
                        accessSecret: $0.access_secret ?? "",
                        enableIPv4: $0.enable_ipv4 ?? false,
                        enableIPv6: $0.enable_ipv6 ?? false,
                        maxRetries: $0.max_retries ?? 0,
                        webhookURL: $0.webhook_url ?? "",
                        webhookMethod: $0.webhook_method ?? 0,
                        webhookRequestType: $0.webhook_request_type ?? 0,
                        webhookRequestBody: $0.webhook_request_body ?? "",
                        webhookHeaders: $0.webhook_headers ?? ""
                    )
                }) ?? []
            }
        }

        try await getDDNSTask?.value
    }
}
