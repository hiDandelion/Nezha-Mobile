//
//  ServerDetailConfigurationIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

import AppIntents

struct ServerDetailConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configure Widget"
    static let description = IntentDescription("Configure Server Detail Widget")

    @Parameter(title: "Server")
    var server: ServerEntity?
    @Parameter(title: "Show IP")
    var isShowIP: Bool?
    @Parameter(title: "Color")
    var color: WidgetBackgroundColor?

    init() {}

    init(server: ServerEntity, isShowIP: Bool, color: WidgetBackgroundColor) {
        self.server = server
        self.isShowIP = isShowIP
        self.color = color
    }
}
