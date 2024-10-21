//
//  NezhaMobileDataHandler.swift
//  NezhaMobileData
//
//  Created by Junhui Lou on 9/20/24.
//

import Foundation
import SwiftUI
import SwiftData

@ModelActor
public actor NezhaMobileDataHandler {
    @discardableResult
    public func newIdentity(name: String, username: String, password: String) throws -> PersistentIdentifier {
        let identity = Identity(name: name, username: username, password: password)
        modelContext.insert(identity)
        try modelContext.save()
        return identity.persistentModelID
    }
    
    public func newIdentity(name: String, username: String, privateKeyString: String, privateKeyType: PrivateKeyType) throws -> PersistentIdentifier {
        let identity = Identity(name: name, username: username, privateKeyString: privateKeyString, privateKeyType: privateKeyType)
        modelContext.insert(identity)
        try modelContext.save()
        return identity.persistentModelID
    }
    
    public func renameIdentity(id: PersistentIdentifier, name: String) throws {
        guard let identity = self[id, as: Identity.self] else { return }
        identity.name = name
        try modelContext.save()
    }
    
    public func deleteIdentity(id: PersistentIdentifier) throws {
        guard let identity = self[id, as: Identity.self] else { return }
        modelContext.delete(identity)
        try modelContext.save()
    }
    
    public func newServerAlert(uuid: UUID, timestamp: Date, title: String?, content: String?) throws -> PersistentIdentifier {
        let serverAlert = ServerAlert(uuid: uuid, timestamp: timestamp, title: title, content: content)
        modelContext.insert(serverAlert)
        try modelContext.save()
        return serverAlert.persistentModelID
    }
    
    public func newServerAlert(timestamp: Date, title: String?, content: String?) throws -> PersistentIdentifier {
        let serverAlert = ServerAlert(timestamp: timestamp, title: title, content: content)
        modelContext.insert(serverAlert)
        try modelContext.save()
        return serverAlert.persistentModelID
    }
    
    public func deleteServerAlert(id: PersistentIdentifier) throws {
        guard let serverAlert = self[id, as: ServerAlert.self] else { return }
        modelContext.delete(serverAlert)
        try modelContext.save()
    }
    
    public func deleteAllServerAlerts() throws {
        try modelContext.delete(model: ServerAlert.self)
        try modelContext.save()
    }
}

public struct DataHandlerKey: EnvironmentKey {
  public static let defaultValue: @Sendable () async -> NezhaMobileDataHandler? = { nil }
}

extension EnvironmentValues {
  public var createDataHandler: @Sendable () async -> NezhaMobileDataHandler? {
    get { self[DataHandlerKey.self] }
    set { self[DataHandlerKey.self] = newValue }
  }
}
