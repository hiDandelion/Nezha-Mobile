//
//  CustomStackView.swift
//  WeatherAppScrolling (iOS)
//
//  Created by Balaji on 15/06/21.
//

import SwiftUI

struct CustomStackView<Title: View, Content: View>: View {
    var titleView: Title
    var contentView: Content
    /// View Properties
    @State var topOffset: CGFloat = 0
    @State var bottomOffset: CGFloat = 0
    private var titleHeight: CGFloat = 38
    
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
                        .opacity(0.6)
                    Spacer()
                }
                .frame(height: titleHeight)
                .padding(.leading, 10)
                
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 150)
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
            self.topOffset = rect.minY
            self.bottomOffset = rect.maxY
        }
    }
    
    /// Opacity
    func getOpacity() -> CGFloat {
        if bottomOffset < titleHeight {
            let progress = bottomOffset < 0 ? 0 : pow(bottomOffset / titleHeight, 3)
            return progress
        }
        
        return 1
    }
}
