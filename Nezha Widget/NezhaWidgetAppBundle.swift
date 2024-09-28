//
//  NezhaWidgetAppBundle.swift
//  Nezha Widget
//
//  Created by Junhui Lou on 8/2/24.
//

import WidgetKit
import SwiftUI

@main
struct WidgetAppBundle: WidgetBundle {
    var body: some Widget {
        ServerDetailWidget()
#if os(iOS)
        AgentWidget()

        if #available(iOS 18.0, *) {
            AgentControlWidget()
        }
        
        if #available(iOS 17.2, *) {
            LiveActivity()
        }
#endif
    }
}
