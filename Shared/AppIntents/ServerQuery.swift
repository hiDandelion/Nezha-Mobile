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
            let response = try await RequestHandler.getAllServerDetail()
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
            let response = try await RequestHandler.getAllServerDetail()
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
