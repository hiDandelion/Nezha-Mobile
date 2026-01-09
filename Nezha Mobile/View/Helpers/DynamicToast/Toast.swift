//
//  Toast.swift
//  DynamicIslandToast
//
//  Created by Balaji Venkatesh on 04/01/26.
//

import SwiftUI

struct Toast {
    private(set) var id: String = UUID().uuidString
    var symbol: String
    var symbolFont: Font
    var symbolForegroundStyle: (Color, Color)
    
    var title: LocalizedStringKey
    var message: LocalizedStringKey
    
    static var defaultToast: Toast {
        Toast(
            symbol: "checkmark.circle.fill",
            symbolFont: .system(size: 35),
            symbolForegroundStyle: (.white, .green),
            title: "Success",
            message: ""
        )
    }
    
    static var successfullyCopied: Toast {
        Toast(
            symbol: "checkmark.circle.fill",
            symbolFont: .system(size: 35),
            symbolForegroundStyle: (.white, .green),
            title: "Success copied",
            message: "Please paste the command on your server."
        )
    }
}
