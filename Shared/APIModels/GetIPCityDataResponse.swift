//
//  GetIPCityDataResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/20/24.
//

struct GetIPCityDataResponse: Codable {
    let message: String
    let result: IPCityData?
}

struct IPCityData: Codable {
    let IP: String
    let continent: String
    let country: String
    let registeredCountry: String
    let city: String
    let location: IPLocation
}

struct IPLocation: Codable {
    let accuracyRadius: Int64?
    let latitude: Double?
    let longitude: Double?
    let timezone: String
}
