//
//  RenamableAndDeletable.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/5/24.
//

import SwiftUI

struct RenamableAndDeletable: ViewModifier {
    let renameAction: () -> Void
    let deleteAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive) {
                    deleteAction()
                }
                Button("Rename") {
                    renameAction()
                }
            }
            .contextMenu {
                Button {
                    renameAction()
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    deleteAction()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension View {
    func renamableAndDeletable(renameAction: @escaping () -> Void, deleteAction: @escaping () -> Void) -> some View {
        modifier(RenamableAndDeletable(renameAction: renameAction, deleteAction: deleteAction))
    }
}
