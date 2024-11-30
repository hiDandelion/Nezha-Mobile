//
//  NezhaDashboardError.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import Foundation

enum NezhaDashboardError: LocalizedError {
    case invalidDashboardConfiguration
    case dashboardAuthenticationFailed
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidDashboardConfiguration:
            return String(localized: "error.invalidDashboardConfiguration")
        case .dashboardAuthenticationFailed:
            return String(localized: "error.dashboardAuthenticationFailed")
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError:
            return "Unable to decode data."
        case .invalidResponse(let message):
            return message
        }
    }
}
