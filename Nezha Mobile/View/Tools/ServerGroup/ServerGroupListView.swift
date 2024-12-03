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
    @State private var isLoading: Bool = false
    
    var body: some View {
        @Bindable var serverGroupViewModel = serverGroupViewModel
        List {
            if !serverGroupViewModel.serverGroups.isEmpty {
                ForEach(serverGroupViewModel.serverGroups) { serverGroup in
                    NavigationLink {
                        ServerGroupDetailView(serverGroupID: serverGroup.serverGroupID)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(nameCanBeUntitled(serverGroup.name))
                            Text("\(serverGroup.serverIDs.count) server(s)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            
                        }
                        .lineLimit(1)
                    }
                }
                .onDelete { indexSet in
                    let serverGroupIDs = indexSet.map { serverGroupViewModel.serverGroups[$0].serverGroupID }
                    Task {
                        isLoading = true
                        do {
                            let _ = try await RequestHandler.deleteServerGroup(serverGroupIDs: serverGroupIDs)
                            await serverGroupViewModel.updateSync()
                            isLoading = false
                        } catch {
                            isLoading = false
#if DEBUG
                            let _ = NMCore.debugLog(error)
#endif
                        }
                    }
                }
            }
            else {
                Text("No Server Group")
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowAddServerGroupAlert = true
                } label: {
                    Label("Add Server Group", systemImage: "plus")
                }
                .alert("Add Server Group", isPresented: $isShowAddServerGroupAlert) {
                    TextField("Name", text: $nameOfNewServerGroup)
                    Button("Cancel", role: .cancel) { }
                    Button("Add") {
                        isLoading = true
                        Task {
                            do {
                                let _ = try await RequestHandler.addServerGroup(name: nameOfNewServerGroup)
                                await serverGroupViewModel.updateSync()
                                isLoading = false
                                nameOfNewServerGroup = ""
                            } catch {
                                isLoading = false
#if DEBUG
                                let _ = NMCore.debugLog(error)
#endif
                            }
                        }
                    }
                } message: {
                    Text("Enter a name for the new server group.")
                }
            }
        }
        .canBeLoading(isLoading: $isLoading)
        .canInLoadingStateModifier(loadingState: $serverGroupViewModel.loadingState) {
            serverGroupViewModel.loadData()
        }
        .navigationTitle("Server Groups")
        .onAppear {
            serverGroupViewModel.loadData()
        }
    }
}
