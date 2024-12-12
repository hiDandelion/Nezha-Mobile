//
//  Schema.swift
//  NezhaMobileData
//
//  Created by Junhui Lou on 9/23/24.
//

import SwiftData

public typealias CurrentSchema = SchemaV2

public enum SchemaV1: VersionedSchema {
  public static var versionIdentifier: Schema.Version {
    .init(1, 0, 0)
  }

  public static var models: [any PersistentModel.Type] {
      [self.Alert.self]
  }
}

public enum SchemaV2: VersionedSchema {
  public static var versionIdentifier: Schema.Version {
    .init(2, 0, 0)
  }

  public static var models: [any PersistentModel.Type] {
      [self.Alert.self, self.Snippet.self]
  }
}
