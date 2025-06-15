//
//  LoadingStateModifier.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct LoadingStateModifier: ViewModifier {
    let loadingState: LoadingState
    let retryAction: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            switch(loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                content
            case .error(let message):
                VStack(spacing: 20) {
                    Text("An error occurred")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                    Button("Retry") {
                        retryAction()
                    }
                }
                .padding()
            }
        }
    }
}

extension View {
    func loadingState(loadingState: LoadingState, retryAction: @escaping () -> Void) -> some View {
        modifier(LoadingStateModifier(loadingState: loadingState, retryAction: retryAction))
    }
}
