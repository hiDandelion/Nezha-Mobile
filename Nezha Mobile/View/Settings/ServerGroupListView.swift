//
//  ServerGroupListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import SwiftUI

struct ServerGroupListView: View {
    @Environment(ServerGroupViewModel.self) private var serverGroupViewModel
    @State private var editMode: EditMode = .inactive
    @State private var isShowAddServerGroupAlert: Bool = false
    @State private var nameOfNewServerGroup: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        @Bindable var serverGroupViewModel = serverGroupViewModel
        List {
            ForEach(serverGroupViewModel.serverGroups) { serverGroup in
                NavigationLink {
                    ServerGroupDetailView(serverGroupID: serverGroup.serverGroupID)
                } label: {
                    VStack(alignment: .leading) {
                        Text(serverGroup.name != "" ? serverGroup.name : "Untitled")
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            
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
                    Text("Enter a name for the new server group")
                }
            }
        }
        .environment(\.editMode, $editMode)
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

struct ServerGroupDetailView: View {
    @Environment(ServerGroupViewModel.self) private var serverGroupViewModel
    let serverGroupID: Int64
    var serverGroup: ServerGroup? {
        serverGroupViewModel.serverGroups.first(where: { $0.serverGroupID == serverGroupID })
    }
    @State private var editMode: EditMode = .inactive
    @State private var selectedServerIDs: Set<Int64> = .init()
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let serverGroup = serverGroup {
                    ServerGroupServerListView(serverGroup: serverGroup, selectedServerIDs: $selectedServerIDs)
                        .navigationTitle(serverGroup.name)
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
            .canBeLoading(isLoading: $isLoading)
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
                Button {
                    isLoading = true
                    Task {
                        do {
                            let _ = try await RequestHandler.updateServerGroup(serverGroup: serverGroup, serverIDs: Array(selectedServerIDs))
                            await serverGroupViewModel.updateSync()
                            withAnimation {
                                editMode = .inactive
                            }
                        } catch {
                            isLoading = false
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
        }
    }
}

struct ServerGroupServerListView: View {
    @Environment(\.editMode) var editMode
    @Environment(ServerGroupViewModel.self) private var serverGroupViewModel
    var serverGroup: ServerGroup
    var serverInGroup: [ServerData] {
        serverGroupViewModel.servers.filter {
            serverGroup.serverIDs.contains($0.serverID)
        }
    }
    @Binding var selectedServerIDs: Set<Int64>
    
    var body: some View {
        if (!serverGroup.serverIDs.isEmpty && editMode?.wrappedValue == .inactive) || (!serverGroupViewModel.servers.isEmpty && editMode?.wrappedValue == .active) {
            List(selection: $selectedServerIDs) {
                if editMode?.wrappedValue == .inactive {
                    ForEach(serverInGroup) { server in
                        ServerTitle(server: server, lastUpdateTime: nil)
                            .tag(server.serverID)
                    }
                }
                if editMode?.wrappedValue == .active {
                    ForEach(serverGroupViewModel.servers) { server in
                        ServerTitle(server: server, lastUpdateTime: nil)
                            .tag(server.serverID)
                    }
                }
            }
        }
        else {
            ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
        }
    }
}
