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
    init() {
        NMCore.registerUserDefaults()
        NMCore.registerKeychain()
    }
    
    var body: some Widget {
        ServerDetailWidget()
#if os(iOS)
        AgentWidget()
#endif
    }
}
