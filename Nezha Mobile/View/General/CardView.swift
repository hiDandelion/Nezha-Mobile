//
//  CardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/5/24.
//

import SwiftUI

struct CardView<Title: View, Content: View, Footer: View>: View {
    var titleView: Title
    var contentView: Content
    var footerView: Footer
    
    init(@ViewBuilder titleView: @escaping () -> Title, @ViewBuilder contentView: @escaping () -> Content, @ViewBuilder footerView: @escaping () -> Footer) {
        self.contentView = contentView()
        self.titleView = titleView()
        self.footerView = footerView()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                titleView
                Spacer()
            }
            .padding(.top, 5)
            .padding(.horizontal, 10)
            
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                footerView
            }
            .padding(.bottom, 5)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }
}
