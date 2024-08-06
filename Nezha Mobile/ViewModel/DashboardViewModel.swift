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

enum DashboardLoadingState {
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
        getAllServerDetail()
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
        getAllServerDetail()
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
        
        getAllServerDetail { [weak self] success in
            self?.scheduleBackgroundRefresh()
            task.setTaskCompleted(success: success)
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.getAllServerDetail()
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
    
    private func getAllServerDetail(completion: ((Bool) -> Void)? = nil) {
        GetServerDetailRequestHandler.getAllServerDetail { [weak self] response, errorDescription in
            DispatchQueue.main.async {
                withAnimation {
                    if let response = response {
                        if let servers = response.result {
                            self?.servers = servers
                        }
                        self?.loadingState = .loaded
                        completion?(true)
                    } else if let errorDescription = errorDescription {
                        self?.loadingState = .error(errorDescription)
                        completion?(false)
                    } else {
                        self?.loadingState = .error(String(localized: "error.unknownError"))
                        completion?(false)
                    }
                }
            }
        }
    }
}
