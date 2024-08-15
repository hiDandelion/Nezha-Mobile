//
//  AppIntent.swift
//  WidgetAppExtension
//
//  Created by Junhui Lou on 8/2/24.
//

import AppIntents
#if os(iOS)
import ActivityKit
#endif

struct ServerQuery: EntityQuery {
    func entities(for identifiers: [ServerEntity.ID]) async throws -> [ServerEntity] {
        do {
            let response = try await RequestHandler.getServerDetail(serverID: "")
            if let servers = response.result {
                let serverEntities = servers.map { ServerEntity(id: $0.id, name: $0.name, displayIndex: $0.displayIndex) }
                let serverEntitiesSorted = serverEntities.sorted {
                    if $0.displayIndex == nil || $0.displayIndex == nil {
                        return $0.id < $1.id
                    }
                    else {
                        if $0.displayIndex == $1.displayIndex {
                            return $0.id < $1.id
                        }
                        else {
                            return $0.displayIndex! > $1.displayIndex!
                        }
                    }
                }
                return serverEntitiesSorted
            }
            return []
        }
        catch {
            return []
        }
    }
    
    func suggestedEntities() async throws -> [ServerEntity] {
        do {
            let response = try await RequestHandler.getServerDetail(serverID: "")
            if let servers = response.result {
                let serverEntities = servers.map { ServerEntity(id: $0.id, name: $0.name, displayIndex: $0.displayIndex) }
                let serverEntitiesSorted = serverEntities.sorted {
                    if $0.displayIndex == nil || $0.displayIndex == nil {
                        return $0.id < $1.id
                    }
                    else {
                        if $0.displayIndex == $1.displayIndex {
                            return $0.id < $1.id
                        }
                        else {
                            return $0.displayIndex! > $1.displayIndex!
                        }
                    }
                }
                return serverEntitiesSorted
            }
            return []
        }
        catch {
            return []
        }
    }
    
    func defaultResult() async -> ServerEntity? {
        try? await suggestedEntities().first
    }
}

struct ServerEntity: AppEntity {
    let id: Int
    let name: String
    let displayIndex: Int?
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    static var defaultQuery = ServerQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

enum WidgetBackgroundColor: String, Codable, Sendable {
    case blue
    case green
    case orange
    case black
}

extension WidgetBackgroundColor: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: LocalizedStringResource("Color"))
    }
    
    static var caseDisplayRepresentations: [WidgetBackgroundColor : DisplayRepresentation] = [
        .blue: DisplayRepresentation(title: "Ocean"),
        .green: DisplayRepresentation(title: "Leaf"),
        .orange: DisplayRepresentation(title: "Maple"),
        .black: DisplayRepresentation(title: "Obsidian"),
    ]
}

@available(iOS 17.0, *)
struct SpecifyServerIDIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Server"
    static var description = IntentDescription("Select the server to display details for.")

    @Parameter(title: "Server")
    var server: ServerEntity
    @Parameter(title: "Show IP")
    var isShowIP: Bool
    @Parameter(title: "Color")
    var color: WidgetBackgroundColor

    init() {
        self.server = ServerEntity(id: -1, name: "Demo", displayIndex: -1)
        self.isShowIP = false
        self.color = .blue
    }

    init(server: ServerEntity, isShowIP: Bool, color: WidgetBackgroundColor) {
        self.server = server
        self.isShowIP = isShowIP
        self.color = color
    }
}

@available(iOS 17.0, *)
struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    static var description = IntentDescription("Get up-to-date details of a server.")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

#if os(iOS)
@available(iOS 17.2, *)
struct RefreshLiveActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Refresh Live Activity"
    static var description = IntentDescription("Get up-to-date details of a server.")
    
    func perform() async throws -> some IntentResult {
        let activities = Activity<LiveActivityAttributes>.activities
        for activity in activities {
            let serverID = activity.content.state.id
            Task {
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
        }
        return .result()
    }
}
#endif
