//
//  DashboardViewModel.swift
//  Watch App Watch App
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
    @Published var servers: [Server] = []
    public var isMonitoringEnabled = false
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Connection": "keep-alive"]
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        self.session = URLSession(configuration: config)
        
        setupNotifications()
    }
    
    func startMonitoring() {
        stopMonitoring()
        isMonitoringEnabled = true
        loadingState = .loading
        getAllServerDetail()
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
        getAllServerDetail()
    }
    
    private func handleEnterBackground() {
        guard isMonitoringEnabled else {
            return
        }
    }
    
    private func getAllServerDetail(completion: ((Bool) -> Void)? = nil) {
        RequestHandler.getAllServerDetail { [weak self] response, errorDescription in
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
