//
//  NezhaMobileData.swift
//  NezhaMobileData
//
//  Created by Junhui Lou on 9/20/24.
//

import SwiftData

public final class NezhaMobileData: Sendable {
    public static let shared = NezhaMobileData()
    
    public let modelContainer: ModelContainer = {
        let schema = Schema([ServerAlert.self, Identity.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }()
    
    public init() {}
    
    public func dataHandlerCreator() -> @Sendable () async -> NezhaMobileDataHandler {
      let modelContainer = modelContainer
      return { NezhaMobileDataHandler(modelContainer: modelContainer) }
    }
}
