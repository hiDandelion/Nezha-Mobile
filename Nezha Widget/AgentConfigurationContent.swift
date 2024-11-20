//
//  AgentConfigurationContent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/28/24.
//

#if os(iOS)
import AppIntents

struct AgentConfigurationContent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configure Widget"
    static let description = IntentDescription("Configure Agent Widget")

    @Parameter(title: "Report")
    var report: Bool?
    @Parameter(title: "Color")
    var color: WidgetBackgroundColor?

    init() {}

    init(report: Bool, color: WidgetBackgroundColor) {
        self.report = report
        self.color = color
    }
}
#endif
