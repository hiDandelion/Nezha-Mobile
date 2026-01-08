//
//  View+getSafeAreaInsets.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/2/24.
//

import SwiftUI

extension View {
    func getSafeAreaInsets() -> UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}
