//
//  AppIntent.swift
//  WidgetAppExtension
//
//  Created by Junhui Lou on 8/2/24.
//

import AppIntents

struct RefreshServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Server"
    static var description = IntentDescription("Get up-to-date info of a server.")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
