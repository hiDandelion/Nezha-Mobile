//
//  DashboardViewModel.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import Foundation
import Combine
import BackgroundTasks
import SwiftUI

enum DashboardLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@Observable
class DashboardViewModel {
    private var timer: Timer?
    var loadingState: DashboardLoadingState = .idle
    var lastUpdateTime: Date?
    var servers: [GetServerDetailResponse.Server] = []
    var isMonitoringEnabled = false
    
    func startMonitoring() {
        stopMonitoring()
        isMonitoringEnabled = true
        loadingState = .loading
        Task {
            await getAllServerDetail()
        }
        startTimer()
    }
    
    func stopMonitoring() {
        stopTimer()
        isMonitoringEnabled = false
        loadingState = .idle
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                await self.getAllServerDetail()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getAllServerDetail(completion: ((Bool) -> Void)? = nil) async {
        do {
            let response = try await RequestHandler.getAllServerDetail()
            DispatchQueue.main.async {
                withAnimation {
                    if let servers = response.result {
                        self.servers = servers
                    }
                    self.loadingState = .loaded
                    self.lastUpdateTime = Date()
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
