//
//  ServerGroupDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/3/24.
//

import SwiftUI

struct ServerGroupDetailView: View {
    @Environment(ServerGroupViewModel.self) private var serverGroupViewModel
    let serverGroupID: Int64
    var serverGroup: ServerGroup? {
        serverGroupViewModel.serverGroups.first(where: { $0.serverGroupID == serverGroupID })
    }
    @State private var editMode: EditMode = .inactive
    @State private var selectedServerIDs: Set<Int64> = .init()
    @State private var isUpdatingServerGroup: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let serverGroup = serverGroup {
                    ServerGroupServerListView(serverGroup: serverGroup, selectedServerIDs: $selectedServerIDs)
                        .navigationTitle(nameCanBeUntitled(serverGroup.name))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
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
                        isUpdatingServerGroup = true
                        Task {
                            do {
                                let _ = try await RequestHandler.updateServerGroup(serverGroup: serverGroup, serverIDs: Array(selectedServerIDs))
                                await serverGroupViewModel.refreshServerGroupSync()
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
