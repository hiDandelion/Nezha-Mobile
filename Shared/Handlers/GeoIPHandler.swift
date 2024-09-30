//
//  GeoIPHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/29/24.
//

import Foundation

enum GeoIPError: Error {
    case invalidConfiguration
    case internalServerError
    case networkError(Error)
    case decodingError
    case invalidResponse(String)
}

extension RequestHandler {
    static func getIPCityData(IP: String, locale: String) async throws -> GetIPCityDataResponse {
        guard let url = URL(string: "https://geoip.hidandelion.com/city?IP=\(IP)&locale=\(locale)") else {
            throw GeoIPError.invalidConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GetIPCityDataResponse.self, from: data)
            
            if response.result != nil {
                return response
            }
            
            throw GeoIPError.invalidResponse(response.message)
        } catch let error as GeoIPError {
            throw error
        } catch let error as DecodingError {
            handleDecodingError(error: error)
            throw error
        } catch {
            throw error
        }
    }
}
