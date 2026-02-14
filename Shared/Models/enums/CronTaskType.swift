//
//  CronTaskType.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

enum CronTaskType: Int64, Codable, Identifiable, CaseIterable {
    var id: Int64 {
        rawValue
    }

    case scheduled = 0
    case triggered = 1

    var title: String {
        switch self {
        case .scheduled: String(localized: "Scheduled")
        case .triggered: String(localized: "Triggered")
        }
    }
}
