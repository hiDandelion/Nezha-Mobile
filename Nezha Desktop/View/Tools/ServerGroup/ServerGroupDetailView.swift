//
//  ServerGroupDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/6/24.
//

import SwiftUI

enum ServerGroupEditMode {
    case inactive
    case active
}

struct ServerGroupDetailView: View {
    @Environment(NMState.self) private var state
    let serverGroupID: Int64
    var serverGroup: ServerGroup? {
        state.serverGroups.first(where: { $0.serverGroupID == serverGroupID })
    }
    @State private var editMode: ServerGroupEditMode = .inactive
    @State private var selectedServerIDs: Set<Int64> = .init()
    @State private var isUpdatingServerGroup: Bool = false
    
    var body: some View {
        if let serverGroup = serverGroup {
            ServerGroupServerListView(editMode: editMode, serverGroup: serverGroup, selectedServerIDs: $selectedServerIDs)
                .navigationTitle(nameCanBeUntitled(serverGroup.name))
                .toolbar {
                    ToolbarItem {
                        editButton(serverGroup: serverGroup)
                    }
                }
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
                    Text("Edit")
                }
            }
            if editMode == .active {
                if !isUpdatingServerGroup {
                    Button {
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
                    } label: {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
    }
}
