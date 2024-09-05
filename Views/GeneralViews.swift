//
//  GeneralViews.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

func pieceOfInfo(systemImage: String?, name: LocalizedStringKey, content: String) -> some View {
    ViewThatFits(in: .horizontal) {
        HStack {
            if let systemImage {
                Label(name, systemImage: systemImage)
            }
            else {
                Text(name)
            }
            
            Spacer()
            
            Text(content)
                .foregroundStyle(.secondary)
        }
        
        VStack(alignment: .leading) {
            if let systemImage {
                Label(name, systemImage: systemImage)
            }
            else {
                Text(name)
            }
            
            Text(content)
                .foregroundStyle(.secondary)
        }
    }
}

func pieceOfInfo(systemImage: String?, name: LocalizedStringKey, content: some View) -> some View {
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
