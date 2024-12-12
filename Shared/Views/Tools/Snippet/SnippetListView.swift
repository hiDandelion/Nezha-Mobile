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
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \TerminalSnippet.timestamp, order: .reverse) private var terminalSnippets: [TerminalSnippet]
    
    @State private var isShowEditSnippetSheet: Bool = false
    
    var body: some View {
        List {
            if !terminalSnippets.isEmpty {
                ForEach(terminalSnippets) { terminalSnippet in
                    NavigationLink {
                        SnippetDetailView(terminalSnippet: terminalSnippet)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(nameCanBeUntitled(terminalSnippet.title))
                            Text(terminalSnippet.content ?? "No Content")
                                .font(.footnote)
                                .monospaced()
                        }
                        .lineLimit(1)
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
        .navigationTitle("Snippets")
        .toolbar {
            Button {
                isShowEditSnippetSheet = true
            } label: {
                Label("Add Snippet", systemImage: "plus")
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
