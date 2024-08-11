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

class DashboardViewModel: ObservableObject {
    private var timer: Timer?
    private var backgroundTask: BGTask?
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    @Published var loadingState: DashboardLoadingState = .idle
    @Published var servers: [Server] = []
    public var isMonitoringEnabled = false
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Connection": "keep-alive"]
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        self.session = URLSession(configuration: config)
        
        registerBackgroundTask()
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
        cancelBackgroundRefresh()
        isMonitoringEnabled = false
        loadingState = .idle
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
        scheduleBackgroundRefresh()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        guard isMonitoringEnabled else {
            task.setTaskCompleted(success: true)
            return
        }
        
        scheduleBackgroundRefresh()
        
        task.expirationHandler = { [weak self] in
            self?.cancelBackgroundRefresh()
            task.setTaskCompleted(success: false)
        }
        
        Task {
            await getAllServerDetail { [weak self] success in
                self?.scheduleBackgroundRefresh()
                task.setTaskCompleted(success: success)
            }
        }
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
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.argsment.Nezha-Mobile.get-all-server-detail", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.argsment.Nezha-Mobile.get-all-server-detail")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func cancelBackgroundRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.argsment.Nezha-Mobile.get-all-server-detail")
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
