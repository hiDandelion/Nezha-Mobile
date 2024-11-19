//
//  NMUI.PieceOfInfo.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

extension NMUI {
    struct PieceOfInfo<Content: View>: View {
        let systemImage: String?
        let name: LocalizedStringKey
        let content: Content
        
        var body: some View {
            ViewThatFits(in: .horizontal) {
                HStack {
                    if let systemImage {
                        Label(name, systemImage: systemImage)
                    }
                    else {
                        Text(name)
                    }
                    
                    Spacer()
                    
                    content
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    if let systemImage {
                        Label(name, systemImage: systemImage)
                    }
                    else {
                        Text(name)
                    }
                    
                    content
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
