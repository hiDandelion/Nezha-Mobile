//
//  CopiableModifier.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/2/26.
//

import SwiftUI

struct CopiableModifier: ViewModifier {
    let text: String
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = text
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
#endif
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                }
            }
    }
}

extension View {
    func copiable(_ text: String) -> some View {
        modifier(CopiableModifier(text: text))
    }
}
