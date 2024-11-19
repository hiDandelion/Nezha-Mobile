//
//  NezhaDashboardDecoder.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import Foundation

extension RequestHandler {
    static func decodeNezhaDashboardResponse<T: Codable & NezhaDashboardBaseResponse>(data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(T.self, from: data)
            
            if response.code == 403 {
                throw NezhaDashboardError.dashboardAuthenticationFailed
            }
            
            if response.code == 0 {
                return response
            }
            
            throw NezhaDashboardError.invalidResponse(response.message)
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
