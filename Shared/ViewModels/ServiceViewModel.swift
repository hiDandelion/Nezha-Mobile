//
//  ServiceViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation
import SwiftUI
import Observation

@Observable
class ServiceViewModel {
    var loadingState: LoadingState = .idle
    var services: [ServiceData] = .init()
    
    func loadData() {
        loadingState = .loading
        Task {
            do {
                try await getServices()
                loadingState = .loaded
            }
            catch {
                withAnimation {
                    self.loadingState = .error(error.localizedDescription)
                }
                return
            }
        }
    }
    
    func refresh() async {
        try? await getServices()
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
}
