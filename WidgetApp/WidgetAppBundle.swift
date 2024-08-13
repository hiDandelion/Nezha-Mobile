//
//  WidgetAppBundle.swift
//  WidgetApp
//
//  Created by Junhui Lou on 8/2/24.
//

import WidgetKit
import SwiftUI

@main
struct WidgetAppBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 17.2, *) {
            LiveActivity()
        }
        WidgetApp()
    }
}
