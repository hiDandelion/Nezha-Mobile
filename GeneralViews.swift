//
//  GeneralViews.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: String) -> some View {
    return HStack {
        Label(name, systemImage: systemImage)
        Spacer()
        Text(content)
            .foregroundStyle(.secondary)
    }
}

func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: some View) -> some View {
    return HStack {
        Label(name, systemImage: systemImage)
        Spacer()
        content
            .foregroundStyle(.secondary)
    }
}

func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: String, isLongContent: Bool = false) -> some View {
    VStack {
        if isLongContent {
            VStack(alignment: .leading) {
                Label(name, systemImage: systemImage)
                Text(content)
                    .foregroundStyle(.secondary)
            }
        }
        else {
            HStack {
                Label(name, systemImage: systemImage)
                Spacer()
                Text(content)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

func pieceOfInfo(systemImage: String, name: LocalizedStringKey, content: some View, isLongContent: Bool = false) -> some View {
    VStack {
        if isLongContent {
            VStack(alignment: .leading) {
                Label(name, systemImage: systemImage)
                Spacer()
                content
                    .foregroundStyle(.secondary)
            }
        }
        else {
            HStack {
                Label(name, systemImage: systemImage)
                Spacer()
                content
                    .foregroundStyle(.secondary)
            }
        }
    }
}
