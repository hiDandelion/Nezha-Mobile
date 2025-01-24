//
//  ServiceType.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/11/24.
//

enum ServiceType: Int64, Identifiable, CaseIterable {
    var id: Int64 {
        rawValue
    }
    
    case get = 1
    case icmp = 2
    case tcping = 3
    
    var title: String {
        switch self {
        case .get: String(localized: "HTTP GET")
        case .icmp: String(localized: "ICMP Ping")
        case .tcping: String(localized: "TCPing")
        }
    }
}
