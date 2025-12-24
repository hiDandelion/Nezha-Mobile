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
                    if let content = terminalSnippet.content {
                        UIPasteboard.general.string = content
                    }
#endif
#if os(macOS)
                    if let content = terminalSnippet.content {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(content, forType: .string)
                    }
#endif
                } label: {
                    Label("Copy Script", systemImage: "doc.on.doc")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(nameCanBeUntitled(terminalSnippet.title))
        .toolbar {
            ToolbarItem {
                Button {
                    isShowEditSnippetSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isShowEditSnippetSheet, content: {
            EditSnippetView(terminalSnippet: terminalSnippet)
        })
    }
}
