//
//  SnippetDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/12/24.
//

import SwiftUI
import NezhaMobileData

struct SnippetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let terminalSnippet: TerminalSnippet
    
    @State private var isShowEditSnippetSheet: Bool = false
    
    var body: some View {
        Form {
            Section("Script") {
                Text(terminalSnippet.content ?? "")
                    .monospaced()
            }
            
            Section {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = terminalSnippet.content
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(terminalSnippet.content, forType: .string)
#endif
                } label: {
                    Label("Copy Script", systemImage: "doc.on.doc")
                }
            }
        }
        .navigationTitle(nameCanBeUntitled(terminalSnippet.title))
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    isShowEditSnippetSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowEditSnippetSheet, content: {
            EditSnippetView(terminalSnippet: terminalSnippet)
        })
    }
}
