//
//  SummaryConfigurationIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/28/25.
//

import AppIntents

struct SummaryConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configure Widget"
    static let description = IntentDescription("Configure Summary Widget")

    @Parameter(title: "Color")
    var color: WidgetBackgroundColor?

    init() {}

    init(color: WidgetBackgroundColor) {
        self.color = color
    }
}
