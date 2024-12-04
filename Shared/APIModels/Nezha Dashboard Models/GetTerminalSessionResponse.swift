//
//  GetTerminalSessionResponse.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/4/24.
//

import Foundation

struct GetTerminalSessionResponse: Codable, NezhaDashboardBaseResponse {
    let success: Bool?
    let error: String?
    let data: Session
    
    struct Session: Codable {
        let session_id: String
    }
}
