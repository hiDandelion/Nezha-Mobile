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
    
    public func newTerminalSnippet(uuid: UUID, timestamp: Date, title: String?, content: String?) throws -> PersistentIdentifier {
        let terminalSnippet = TerminalSnippet(uuid: uuid, timestamp: timestamp, title: title, content: content)
        modelContext.insert(terminalSnippet)
        try modelContext.save()
        return terminalSnippet.persistentModelID
    }
    
    public func newTerminalSnippet(timestamp: Date, title: String?, content: String?) throws -> PersistentIdentifier {
        let terminalSnippet = TerminalSnippet(timestamp: timestamp, title: title, content: content)
        modelContext.insert(terminalSnippet)
        try modelContext.save()
        return terminalSnippet.persistentModelID
    }
    
    public func updateTerminalSnippet(id: PersistentIdentifier, title: String) throws {
        guard let terminalSnippet = self[id, as: TerminalSnippet.self] else { return }
        terminalSnippet.title = title
        try modelContext.save()
    }
    
    public func updateTerminalSnippet(id: PersistentIdentifier, title: String, content: String) throws {
        guard let terminalSnippet = self[id, as: TerminalSnippet.self] else { return }
        terminalSnippet.title = title
        terminalSnippet.content = content
        try modelContext.save()
    }
    
    public func deleteTerminalSnippet(id: PersistentIdentifier) throws {
        guard let terminalSnippet = self[id, as: TerminalSnippet.self] else { return }
        modelContext.delete(terminalSnippet)
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
