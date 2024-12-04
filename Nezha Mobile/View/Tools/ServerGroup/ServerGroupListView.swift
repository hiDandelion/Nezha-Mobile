//
//  ServerGroupListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import SwiftUI

struct ServerGroupListView: View {
    @Environment(ServerGroupViewModel.self) private var serverGroupViewModel
    
    @State private var isShowAddServerGroupAlert: Bool = false
    @State private var nameOfNewServerGroup: String = ""
    @State private var isAddingServerGroup: Bool = false
    
    @State private var isShowRenameServerGroupAlert: Bool = false
    @State private var serverGroupToRename: ServerGroup?
    @State private var newNameOfServerGroup: String = ""
    
    var body: some View {
        @Bindable var serverGroupViewModel = serverGroupViewModel
        List {
            if !serverGroupViewModel.serverGroups.isEmpty {
                ForEach(serverGroupViewModel.serverGroups) { serverGroup in
                    NavigationLink {
                        ServerGroupDetailView(serverGroupID: serverGroup.serverGroupID)
                    } label: {
                        serverGroupLabel(serverGroup: serverGroup)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    let _ = try await RequestHandler.deleteServerGroup(serverGroups: [serverGroup])
                                    await serverGroupViewModel.refreshServerGroupSync()
                                } catch {
#if DEBUG
                                    let _ = NMCore.debugLog(error)
#endif
                                }
                            }
                        }
                        Button("Rename") {
                            serverGroupToRename = serverGroup
                            newNameOfServerGroup = serverGroup.name
                            isShowRenameServerGroupAlert = true
                        }
                    }
                }
            }
            else {
                Text("No Server Group")
                    .foregroundStyle(.secondary)
            }
        }
        .canInLoadingStateModifier(loadingState: serverGroupViewModel.loadingState) {
            serverGroupViewModel.loadData()
        }
        .navigationTitle("Server Groups")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    serverGroupViewModel.loadData()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
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
        .onAppear {
            if serverGroupViewModel.loadingState == .idle {
                serverGroupViewModel.loadData()
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
                        await serverGroupViewModel.refreshServerGroupSync()
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
                Task {
                    do {
                        let _ = try await RequestHandler.updateServerGroup(serverGroup: serverGroupToRename!, name: newNameOfServerGroup)
                        await serverGroupViewModel.refreshServerGroupSync()
                        newNameOfServerGroup = ""
                    } catch {
#if DEBUG
                        let _ = NMCore.debugLog(error)
#endif
                    }
                }
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
}