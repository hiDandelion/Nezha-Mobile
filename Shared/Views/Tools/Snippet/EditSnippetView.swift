//
//  EditSnippetView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/12/24.
//

import SwiftUI
import NezhaMobileData

struct EditSnippetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.createDataHandler) private var createDataHandler
    let terminalSnippet: TerminalSnippet?
    
    @State private var name: String = ""
    @State private var content: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section("Script") {
                    TextEditor(text: $content)
                        .monospaced()
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
#endif
                }
            }
            .formStyle(.grouped)
            .navigationTitle(terminalSnippet != nil ? "Edit Snippet" : "Add Snippet")
#if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let terminalSnippet {
                            let createDataHandler = createDataHandler
                            Task {
                                if let dataHandler = await createDataHandler() {
                                    _ = try await dataHandler.updateTerminalSnippet(id: terminalSnippet.persistentModelID, title: name, content: content)
                                    dismiss()
                                }
                            }
                        }
                        else {
                            let createDataHandler = createDataHandler
                            Task {
                                if let dataHandler = await createDataHandler() {
                                    _ = try await dataHandler.newTerminalSnippet(timestamp: Date(), title: name, content: content)
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
            }
            .onAppear {
                if let terminalSnippet {
                    name = terminalSnippet.title ?? ""
                    content = terminalSnippet.content ?? ""
                }
            }
        }
    }
}
