//
//  CoverageType.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

enum CoverageType: Int64, Codable, Identifiable, CaseIterable {
    var id: Int64 {
        rawValue
    }

    case only = 0
    case excludes = 1
    case alarmed = 2

    var title: String {
        switch self {
        case .only: String(localized: "Run on specific servers")
        case .excludes: String(localized: "Exclude specific servers")
        case .alarmed: String(localized: "Run on alert-triggered server")
        }
    }
}
