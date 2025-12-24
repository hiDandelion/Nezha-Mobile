//
//  SortIndicator.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/24/25.
//

enum SortIndicator: CaseIterable {
    case index
    case uptime
    case cpu
    case memory
    case disk
    case send
    case receive
    
    var title: String {
        switch self {
        case .index: String(localized: "Default")
        case .uptime: String(localized: "Up Time")
        case .cpu: String(localized: "CPU")
        case .memory: String(localized: "Memory")
        case .disk: String(localized: "Disk")
        case .send: String(localized: "Network Send")
        case .receive: String(localized: "Network Receive")
        }
    }
}
