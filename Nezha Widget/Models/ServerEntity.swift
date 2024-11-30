//
//  ServerEntity.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

import AppIntents

struct ServerEntity: AppEntity {
    let id: String
    let serverID: Int64
    let name: String
    let displayIndex: Int64?
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    static let defaultQuery = ServerQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}
