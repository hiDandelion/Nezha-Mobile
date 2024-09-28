//
//  RefreshLiveActivityIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

#if os(iOS)
import ActivityKit
import AppIntents

struct RefreshLiveActivityIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Refresh Live Activity"
    static let description = IntentDescription("Get up-to-date details of a server.")
    
    func perform() async throws -> some IntentResult {
        let activities = Activity<LiveActivityAttributes>.activities
        for activity in activities {
            let serverID = activity.content.state.id
            do {
                let response = try await RequestHandler.getServerDetail(serverID: String(serverID))
                if let server = response.result?.first {
                    let newContent = ActivityContent(state: LiveActivityAttributes.ContentState(name: server.name, id: server.id, cpu: server.status.cpu, memUsed: server.status.memUsed, diskUsed: server.status.diskUsed, memTotal: server.host.memTotal, diskTotal: server.host.diskTotal, netInTransfer: server.status.netInTransfer, netOutTransfer: server.status.netOutTransfer, load1: server.status.load1, uptime: server.status.uptime), staleDate: Date(timeIntervalSinceNow: 5 * 60))
                    await activity.update(newContent)
                }
            }
            catch {
                
            }
        }
        return .result()
    }
}
#endif
