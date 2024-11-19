//
//  NezhaDashboardError.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

enum NezhaDashboardError: Error {
    case invalidDashboardConfiguration
    case dashboardAuthenticationFailed
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}
