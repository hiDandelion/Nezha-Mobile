//
//  ServerGroupViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import Foundation
import SwiftUI
import Observation

enum ServerGroupLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@Observable
class ServerGroupViewModel {
    var loadingState: LoadingState = .idle
    var servers: [ServerData] = .init()
    var serverGroups: [ServerGroup] = .init()
    
    func loadData() {
        loadingState = .loading
        Task {
            await getServer()
            await getServerGroup()
            loadingState = .loaded
        }
    }
    
    func updateSync() async {
        await getServer()
        await getServerGroup()
    }
    
    func updateAsync() {
        Task {
            await getServer()
            await getServerGroup()
        }
    }
    
    private func getServer() async {
        do {
            let response = try await RequestHandler.getServer()
            DispatchQueue.main.async {
                withAnimation {
                    if let servers = response.data {
                        self.servers = servers.map({
                            ServerData(
                                id: $0.uuid,
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
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    private func getServerGroup() async {
        do {
            let response = try await RequestHandler.getServerGroup()
            DispatchQueue.main.async {
                withAnimation {
                    if let serverGroups = response.data {
                        self.serverGroups = serverGroups.map({
                            ServerGroup(id: UUID().uuidString, serverGroupID: $0.group.id, name: $0.group.name, serverIDs: $0.servers ?? .init())
                        })
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
}
