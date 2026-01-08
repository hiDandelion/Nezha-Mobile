//
//  TopSafeAreaBarModifier.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/8/26.
//

import SwiftUI

struct TopSafeAreaBarModifier<ContentView: View>: ViewModifier {
    let content: () -> ContentView
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            content
                .safeAreaBar(edge: .top, content: self.content)
        } else {
            content
        }
    }
}


extension View {
    func topSafeAreaBar(@ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(TopSafeAreaBarModifier(content: content))
    }
}
