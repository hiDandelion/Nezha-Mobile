//
//  ServerQuery.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

import AppIntents

struct ServerQuery: EntityQuery {
    func entities(for identifiers: [ServerEntity.ID]) async throws -> [ServerEntity] {
        do {
            let response = try await RequestHandler.getAllServer()
            if let servers = response.data {
                let serverEntities = servers.map { ServerEntity(id: $0.uuid, serverID: $0.id, name: $0.name, displayIndex: $0.display_index) }
                let serverEntitiesSorted = serverEntities.sorted {
                    if $0.displayIndex == $1.displayIndex {
                        return $0.id < $1.id
                    }
                    else {
                        return $0.displayIndex! > $1.displayIndex!
                    }
                }
                let serverEntitiesSortedAndFiltered = serverEntitiesSorted.filter {
                    identifiers.contains($0.id)
                }
                return serverEntitiesSortedAndFiltered
            }
            return []
        }
        catch {
            return []
        }
    }
    
    func suggestedEntities() async throws -> [ServerEntity] {
        do {
            let response = try await RequestHandler.getAllServer()
            if let servers = response.data {
                let serverEntities = servers.map { ServerEntity(id: $0.uuid, serverID: $0.id, name: $0.name, displayIndex: $0.display_index) }
                let serverEntitiesSorted = serverEntities.sorted {
                    if $0.displayIndex == $1.displayIndex {
                        return $0.id < $1.id
                    }
                    else {
                        return $0.displayIndex! > $1.displayIndex!
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
