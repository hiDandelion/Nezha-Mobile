//
//  CanBeLoadingModifier.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct CanBeLoadingModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
    }
}

extension View {
    func canBeLoading(isLoading: Bool) -> some View {
        modifier(CanBeLoadingModifier(isLoading: isLoading))
    }
}
