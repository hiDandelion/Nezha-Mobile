//
//  DashboardViewModel.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import Foundation
import Combine
import SwiftUI

enum DashboardLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

class DashboardViewModel: ObservableObject {
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    @Published var loadingState: DashboardLoadingState = .idle
    @Published var servers: [ServerData] = []
    public var isMonitoringEnabled = false
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
        
        setupNotifications()
    }
    
    func startMonitoring() {
        stopMonitoring()
        isMonitoringEnabled = true
        loadingState = .loading
        Task {
            await getAllServerDetail()
        }
    }
    
    func stopMonitoring() {
        isMonitoringEnabled = false
        loadingState = .idle
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: WKApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleEnterForeground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: WKApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleEnterBackground()
            }
            .store(in: &cancellables)
    }
    
    private func handleEnterForeground() {
        guard isMonitoringEnabled else {
            return
        }
        loadingState = .loading
        Task {
            await getAllServerDetail()
        }
    }
    
    private func handleEnterBackground() {
        guard isMonitoringEnabled else {
            return
        }
    }
    
    private func getAllServerDetail(completion: ((Bool) -> Void)? = nil) async {
        do {
            let response = try await RequestHandler.getAllServer()
            DispatchQueue.main.async {
                withAnimation {
                    if let servers = response.data {
                        self.servers = servers.map({
                            ServerData(
                                id: $0.uuid,
                                serverID: $0.id,
                                name: $0.name,
                                tag: "Default",
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
                                    networkOut: $0.state.net_out_speed ?? 0,
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
                        })
                    }
                    self.loadingState = .loaded
                }
            }
            completion?(true)
        }
        catch {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
            completion?(false)
        }
    }
}
