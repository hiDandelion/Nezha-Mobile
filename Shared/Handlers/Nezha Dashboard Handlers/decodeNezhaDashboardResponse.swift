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
            
            if response.success == true {
                return response
            }
            
            throw NezhaDashboardError.invalidResponse(response.error ?? "Unknown error")
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
