//
//  AgentControlWidget.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/28/24.
//

#if os(iOS)
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct AgentControlWidget: ControlWidget {
    static let kind: String = "AgentControlWidget"
    
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetButton("Report", action: ReportDeviceInfoIntent()) { isActive in
                Image(systemName: "square.and.arrow.up.on.square")
                if isActive {
                    Text("Reporting")
                }
            }
        }
        .displayName("Agent")
        .description("Report your device information.")
    }
}
#endif
