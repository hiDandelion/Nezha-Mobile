//
//  TriggerMode.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

enum TriggerMode: Int64, Codable, Identifiable, CaseIterable {
    var id: Int64 {
        rawValue
    }

    case always = 0
    case once = 1

    var title: String {
        switch self {
        case .always: String(localized: "Always")
        case .once: String(localized: "Once")
        }
    }
}
