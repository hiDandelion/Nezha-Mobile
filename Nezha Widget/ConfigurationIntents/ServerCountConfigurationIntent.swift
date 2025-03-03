//
//  ServerCountConfigurationIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/28/25.
//

import AppIntents

struct ServerCountConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configure Widget"
    static let description = IntentDescription("Configure Server Count Widget")
    
    @Parameter(title: "Hide Offline")
    var isHideOffline: Bool?
    @Parameter(title: "Color")
    var color: WidgetBackgroundColor?

    init() {}

    init(isHideOffline: Bool, color: WidgetBackgroundColor) {
        self.isHideOffline = isHideOffline
        self.color = color
    }
}
