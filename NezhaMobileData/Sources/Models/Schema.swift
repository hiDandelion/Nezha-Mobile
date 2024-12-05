//
//  Schema.swift
//  NezhaMobileData
//
//  Created by Junhui Lou on 9/23/24.
//

import SwiftData

public typealias CurrentSchema = SchemaV1

public enum SchemaV1: VersionedSchema {
  public static var versionIdentifier: Schema.Version {
    .init(1, 0, 0)
  }

  public static var models: [any PersistentModel.Type] {
      [ServerAlert.self]
  }
}
