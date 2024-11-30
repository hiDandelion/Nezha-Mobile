//
//  LoginResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/28/24.
//

import Foundation

struct LoginResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: LoginData?
    
    struct LoginData: Codable {
        let token: String
    }
}
