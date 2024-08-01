//
//  DashboardViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import Combine
import SwiftUI

enum DashboardLoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

class DashboardViewModel: ObservableObject {
    @Published var socketResponse: SocketResponse?
    @Published var servers: [Int: Server] = [:]
    @Published var loadingState: DashboardLoadingState = .idle
    @Published var isConnected: Bool = false
    private var socketHandler: SocketHandler
    
    init() {
        socketHandler = SocketHandler()
        socketHandler.delegate = self
    }
    
    func connect(to: String) {
        guard !socketHandler.isConnected else { return }
        loadingState = .loading
        if let url = URL(string: to) {
            socketHandler.connect(to: url)
        }
    }
    
    func disconnect() {
        guard socketHandler.isConnected else { return }
        socketHandler.disconnect()
        loadingState = .idle
    }
}

extension DashboardViewModel: SocketHandlerDelegate {
    func didReceiveServerResponse(_ socketResponse: SocketResponse) {
        DispatchQueue.main.async {
            withAnimation {
                self.socketResponse = socketResponse
                for server in socketResponse.servers {
                    self.servers[server.id] = server
                }
                self.loadingState = .loaded
            }
        }
    }
    
    func didEncounterError(_ error: Error) {
        DispatchQueue.main.async {
            self.loadingState = .error(error.localizedDescription)
        }
    }
}
