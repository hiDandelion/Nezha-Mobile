//
//  RefreshWidgetIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

import AppIntents

struct RefreshWidgetIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh Widget"
    static let description = IntentDescription("Get up-to-date information.")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
