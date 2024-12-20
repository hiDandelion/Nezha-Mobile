//
//  CanInLoadingStateModifier.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct CanInLoadingStateModifier: ViewModifier {
    let loadingState: LoadingState
    let retryAction: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            switch(loadingState) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading...")
                    .transaction { transaction in
                        transaction.animation = nil
                    }
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
    func canInLoadingStateModifier(loadingState: LoadingState, retryAction: @escaping () -> Void) -> some View {
        modifier(CanInLoadingStateModifier(loadingState: loadingState, retryAction: retryAction))
    }
}
