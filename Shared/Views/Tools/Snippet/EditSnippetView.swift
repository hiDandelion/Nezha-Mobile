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
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) {
                            dismiss()
                        }
                    }
                    else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Done", systemImage: "checkmark", role: .confirm) {
                            execute()
                        }
                    }
                    else {
                        Button("Done") {
                            execute()
                        }
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
    
    private func execute() {
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
    }
}
