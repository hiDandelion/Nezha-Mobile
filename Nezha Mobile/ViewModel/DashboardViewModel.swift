//
//  DashboardViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
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
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    var loadingState: DashboardLoadingState = .idle
    var lastUpdateTime: Date?
    var servers: [Server] = []
    var isMonitoringEnabled = false
    
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
        startTimer()
    }
    
    func stopMonitoring() {
        stopTimer()
        isMonitoringEnabled = false
        loadingState = .idle
    }
    
    func updateImmediately() {
        Task {
            await self.getAllServerDetail()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleEnterForeground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
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
        startTimer()
    }
    
    private func handleEnterBackground() {
        guard isMonitoringEnabled else {
            return
        }
        stopTimer()
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
