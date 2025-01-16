//
//  ColorfulView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/16/25.
//

import SwiftUI
import ColorfulX

extension NMUI {
    static func ColorfulView(theme: NMTheme, scheme: ColorScheme) -> some View {
        ColorfulX.ColorfulView(color: theme.themeBackgroundColor(scheme: scheme))
    }
}
