//
//  ServerMetricsTimeSeries.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import Foundation

struct MetricsDataPlot: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ServerMetricsTimeSeries: Identifiable {
    let id = UUID()
    let metric: String
    let plots: [MetricsDataPlot]

    var localizedTitle: String {
        switch metric {
        case "cpu": String(localized: "CPU")
        case "memory": String(localized: "Memory")
        case "swap": String(localized: "Swap")
        case "disk": String(localized: "Disk")
        case "net_in_speed": String(localized: "Network Receive")
        case "net_out_speed": String(localized: "Network Send")
        default: metric
        }
    }

    var systemImage: String {
        switch metric {
        case "cpu": "cpu"
        case "memory": "memorychip"
        case "swap": "arrow.triangle.swap"
        case "disk": "internaldrive"
        case "net_in_speed": "arrow.down.circle"
        case "net_out_speed": "arrow.up.circle"
        default: "chart.xyaxis.line"
        }
    }

    var isPercentage: Bool {
        switch metric {
        case "cpu", "memory", "swap", "disk": true
        default: false
        }
    }
}
