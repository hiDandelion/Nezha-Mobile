//
//  ServerGroupDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/3/24.
//

import SwiftUI

struct ServerGroupDetailView: View {
    @Environment(NMState.self) private var state
    let serverGroupID: Int64
    var serverGroup: ServerGroup? {
        state.serverGroups.first(where: { $0.serverGroupID == serverGroupID })
    }
    @State private var editMode: EditMode = .inactive
    @State private var selectedServerIDs: Set<Int64> = .init()
    @State private var isUpdatingServerGroup: Bool = false
    
    var body: some View {
        if let serverGroup = serverGroup {
            ServerGroupServerListView(serverGroup: serverGroup, selectedServerIDs: $selectedServerIDs)
                .navigationTitle(nameCanBeUntitled(serverGroup.name))
                .toolbar {
                    ToolbarItem {
                        editButton(serverGroup: serverGroup)
                    }
                }
                .environment(\.editMode, $editMode)
                .onChange(of: editMode) {
                    if editMode == .active {
                        selectedServerIDs = Set(serverGroup.serverIDs)
                    }
                }
        }
    }
    
    private func editButton(serverGroup: ServerGroup) -> some View {
        Group {
            if editMode == .inactive {
                Button {
                    withAnimation {
                        editMode = .active
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            if editMode == .active {
                if !isUpdatingServerGroup {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Done", systemImage: "checkmark", role: .confirm) {
                            execute(serverGroup: serverGroup)
                        }
                    }
                    else {
                        Button("Done") {
                            execute(serverGroup: serverGroup)
                        }
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
    }
    
    private func execute(serverGroup: ServerGroup) {
        let selectedServerIDArray = Array(selectedServerIDs)
        guard selectedServerIDArray != serverGroup.serverIDs else {
            withAnimation {
                editMode = .inactive
            }
            return
        }
        isUpdatingServerGroup = true
        Task {
            do {
                let _ = try await RequestHandler.updateServerGroup(serverGroup: serverGroup, serverIDs: selectedServerIDArray)
                await state.refreshServerGroup()
                isUpdatingServerGroup = false
                withAnimation {
                    editMode = .inactive
                }
            } catch {
                isUpdatingServerGroup = false
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
