//
//  AppIntent.swift
//  WidgetAppExtension
//
//  Created by Junhui Lou on 8/2/24.
//

import AppIntents

struct ServerQuery: EntityQuery {
    func entities(for identifiers: [ServerEntity.ID]) async throws -> [ServerEntity] {
        do {
            let response = try await RequestHandler.getServerDetail(serverID: "")
            if let servers = response.result {
                let serverEntities = servers.map { ServerEntity(id: $0.id, name: $0.name, displayIndex: $0.displayIndex) }
                let serverEntitiesSorted = serverEntities.sorted { $0.displayIndex == $1.displayIndex ? ($0.id < $1.id) : ($0.displayIndex > $1.displayIndex) }
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
                let serverEntitiesSorted = serverEntities.sorted { $0.displayIndex == $1.displayIndex ? ($0.id < $1.id) : ($0.displayIndex > $1.displayIndex) }
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
    let displayIndex: Int
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    static var defaultQuery = ServerQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct SpecifyServerIDIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Server"
    static var description = IntentDescription("Select the server to display details for.")

    @Parameter(title: "Server")
    var server: ServerEntity

    init() {
        self.server = ServerEntity(id: 0, name: "Default", displayIndex: 0)
    }

    init(server: ServerEntity) {
        self.server = server
    }
}

struct RefreshServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Server"
    static var description = IntentDescription("Get up-to-date details of a server.")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
