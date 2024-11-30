//
//  MillisecondTimestamps.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import Foundation

@propertyWrapper
struct MillisecondTimestamps {
    var wrappedValue: [Date]
    
    init(wrappedValue: [Date]) {
        self.wrappedValue = wrappedValue
    }
}

extension MillisecondTimestamps: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timestamps = try container.decode([Int64].self)
        wrappedValue = timestamps.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000.0) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let timestamps = wrappedValue.map { Int64($0.timeIntervalSince1970 * 1000) }
        try container.encode(timestamps)
    }
}
