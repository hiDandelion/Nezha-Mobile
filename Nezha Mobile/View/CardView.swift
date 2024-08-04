//
//  CustomStackView.swift
//  WeatherAppScrolling (iOS)
//
//  Created by Balaji on 15/06/21.
//

import SwiftUI

struct CardView<Title: View, Content: View>: View {
    var titleView: Title
    var contentView: Content
    /// View Properties
    @State var topOffset: CGFloat = 0
    @State var bottomOffset: CGFloat = 160
    private var cardHeight: CGFloat = 160
    private var titleHeight: CGFloat = 35
    
    init(@ViewBuilder titleView: @escaping () -> Title, @ViewBuilder contentView: @escaping () -> Content) {
        self.contentView = contentView()
        self.titleView = titleView()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    titleView
                        .font(.callout)
                        .opacity(0.8)
                    Spacer()
                }
                .frame(height: titleHeight)
                .padding(.horizontal, 10)
                
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: cardHeight)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .mask(alignment: .top) {
            Rectangle()
                .frame(height: bottomOffset < titleHeight ? titleHeight : bottomOffset)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
        }
        .opacity(getOpacity())
        .cornerRadius(12)
        .offset(y: max(0, -topOffset))
        .offsetChange { rect in
            withAnimation {
                self.topOffset = rect.minY
                self.bottomOffset = rect.maxY
            }
        }
    }
    
    /// Opacity
    func getOpacity() -> CGFloat {
        if bottomOffset < titleHeight {
            let progress = bottomOffset < 0 ? 0 : pow(bottomOffset / titleHeight, 2)
            return progress
        }
        
        return 1
    }
}
