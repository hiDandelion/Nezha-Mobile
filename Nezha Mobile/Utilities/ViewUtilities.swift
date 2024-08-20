//
//  ViewUtilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/2/24.
//

import SwiftUI

// Offset Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// Handle Offset Change
extension View {
    @ViewBuilder
    func offsetChange(offset: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: OffsetKey.self, value: geometry.frame(in: .global))
                        .onPreferenceChange(OffsetKey.self) { value in
                            DispatchQueue.main.async {
                                let safeArea = getSafeAreaInsets()
                                let adjustedRect = CGRect(
                                    x: value.minX,
                                    y: value.minY - safeArea.top,
                                    width: value.width,
                                    height: value.height
                                )
                                offset(adjustedRect)
                            }
                        }
                }
            }
    }
}

// Get Safe Area Insets
extension View {
    func getSafeAreaInsets() -> UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}
