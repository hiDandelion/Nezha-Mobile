//
//  CardView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/5/24.
//

import SwiftUI

struct CardView<Title: View, Content: View>: View {
    var titleView: Title
    var contentView: Content
    
    init(@ViewBuilder titleView: @escaping () -> Title, @ViewBuilder contentView: @escaping () -> Content) {
        self.contentView = contentView()
        self.titleView = titleView()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                titleView
                Spacer()
            }
            .padding(.bottom, 10)
            
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
