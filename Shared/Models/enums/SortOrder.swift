//
//  SortOrder.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/24/25.
//

enum SortOrder {
    case ascending
    case descending
    
    var title: String {
        switch self {
        case .ascending: String(localized: "Ascending")
        case .descending: String(localized: "Descending")
        }
    }
}
