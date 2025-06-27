//
//  ServerGroupListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import SwiftUI

struct ServerGroupListView: View {
    @Environment(NMState.self) private var state
    
    @State private var isShowAddServerGroupAlert: Bool = false
    @State private var nameOfNewServerGroup: String = ""
    @State private var isAddingServerGroup: Bool = false
    
    @State private var isShowRenameServerGroupAlert: Bool = false
    @State private var serverGroupToRename: ServerGroup?
    @State private var newNameOfServerGroup: String = ""
    
    var body: some View {
        List {
            if !state.serverGroups.isEmpty {
                ForEach(state.serverGroups) { serverGroup in
                    NavigationLink(value: serverGroup) {
                        serverGroupLabel(serverGroup: serverGroup)
                    }
                    .renamableAndDeletable {
                        showRenameServerGroupAlert(serverGroup: serverGroup)
                    } deleteAction: {
                        deleteServerGroup(serverGroup: serverGroup)
                    }
                }
            }
            else {
                Text("No Server Group")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.dashboardLoadingState) {
            state.loadDashboard()
        }
        .navigationTitle("Server Groups")
        .toolbar {
            ToolbarItem {
                if !isAddingServerGroup {
                    Button {
                        isShowAddServerGroupAlert = true
                    } label: {
                        Label("Add Server Group", systemImage: "plus")
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
        .alert("Add Server Group", isPresented: $isShowAddServerGroupAlert) {
            TextField("Name", text: $nameOfNewServerGroup)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                isAddingServerGroup = true
                Task {
                    do {
                        let _ = try await RequestHandler.addServerGroup(name: nameOfNewServerGroup)
                        await state.refreshServerGroup()
                        isAddingServerGroup = false
                        nameOfNewServerGroup = ""
                    } catch {
                        isAddingServerGroup = false
#if DEBUG
                        let _ = NMCore.debugLog(error)
#endif
                    }
                }
            }
        } message: {
            Text("Enter a name for the new server group.")
        }
        .alert("Rename Server Group", isPresented: $isShowRenameServerGroupAlert) {
            TextField("Name", text: $newNameOfServerGroup)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameServerGroup(serverGroup: serverGroupToRename!)
            }
        } message: {
            Text("Enter a new name for the server group.")
        }
    }
    
    private func serverGroupLabel(serverGroup: ServerGroup) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(serverGroup.name))
            Text("\(serverGroup.serverIDs.count) server(s)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
        }
        .lineLimit(1)
    }
    
    private func deleteServerGroup(serverGroup: ServerGroup) {
        Task {
            do {
                let _ = try await RequestHandler.deleteServerGroup(serverGroups: [serverGroup])
                await state.refreshServerGroup()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
    
    private func showRenameServerGroupAlert(serverGroup: ServerGroup) {
        serverGroupToRename = serverGroup
        newNameOfServerGroup = serverGroup.name
        isShowRenameServerGroupAlert = true
    }
    
    private func renameServerGroup(serverGroup: ServerGroup) {
        Task {
            do {
                let _ = try await RequestHandler.updateServerGroup(serverGroup: serverGroupToRename!, name: newNameOfServerGroup)
                await state.refreshServerGroup()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
