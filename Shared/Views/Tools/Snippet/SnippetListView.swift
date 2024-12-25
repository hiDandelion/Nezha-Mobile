//
//  SnippetListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/12/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct SnippetListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \TerminalSnippet.timestamp, order: .reverse) private var terminalSnippets: [TerminalSnippet]
    let executeAction: ((TerminalSnippet) -> Void)?
    
    @State private var isShowEditSnippetSheet: Bool = false
    
    var body: some View {
        List {
            if !terminalSnippets.isEmpty {
                ForEach(terminalSnippets) { terminalSnippet in
                    NavigationLink(value: terminalSnippet) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(nameCanBeUntitled(terminalSnippet.title))
                                Text(terminalSnippet.content ?? "No Content")
                                    .font(.footnote)
                                    .monospaced()
                            }
                            .lineLimit(1)
                            
                            if executeAction != nil {
                                Spacer()
                                Button("Execute") {
                                    executeAction?(terminalSnippet)
                                    dismiss()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                deleteSnippet(terminalSnippet: terminalSnippet)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteSnippet(terminalSnippet: terminalSnippet)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            else {
                Text("No Snippet")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 300)
        .navigationTitle("Snippets")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowEditSnippetSheet = true
                } label: {
                    Label("Add Snippet", systemImage: "plus")
                }
            }
            
            if executeAction != nil {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowEditSnippetSheet, content: {
            EditSnippetView(terminalSnippet: nil)
        })
    }
    
    private func deleteSnippet(terminalSnippet: TerminalSnippet) {
        let createDataHandler = createDataHandler
        Task {
            if let dataHandler = await createDataHandler() {
                _ = try await dataHandler.deleteTerminalSnippet(id: terminalSnippet.persistentModelID)
            }
        }
    }
}
