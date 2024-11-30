//
//  ISO8601Date.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/26/24.
//

import Foundation

@propertyWrapper
struct ISO8601Date: Codable {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
            .withTimeZone
        ]
        return formatter
    }()
    
    var wrappedValue: Date
    
    init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        guard let date = Self.formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match ISO 8601 format"
            )
        }
        
        self.wrappedValue = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let dateString = Self.formatter.string(from: wrappedValue)
        try container.encode(dateString)
    }
}
