//
//  GeoIPError.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

enum GeoIPError: Error {
    case invalidConfiguration
    case internalServerError
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}
