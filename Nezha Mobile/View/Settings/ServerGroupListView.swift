//
//  ServerGroupListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/30/24.
//

import SwiftUI

struct ServerGroupListView: View {
    var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(dashboardViewModel.serverGroups) { serverGroup in
                    NavigationLink {
                        ServerGroupDetailView(dashboardViewModel: dashboardViewModel, serverGroupID: serverGroup.serverGroupID)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(serverGroup.name)
                            Text("\(serverGroup.serverIDs.count) server(s)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                
                        }
                        .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Server Groups")
        }
    }
    
    struct ServerGroupDetailView: View {
        var dashboardViewModel: DashboardViewModel
        let serverGroupID: Int64
        var serverGroup: ServerGroup? {
            dashboardViewModel.serverGroups.first(where: { $0.serverGroupID == serverGroupID })
        }
        @State private var editMode: EditMode = .inactive
        @State private var selectedServerIDs: Set<Int64> = .init()
        @State private var isUpdatingServerGroup: Bool = false
        
        var body: some View {
            NavigationStack {
                ZStack {
                    if let serverGroup = serverGroup {
                        ServerListView(dashboardViewModel: dashboardViewModel, serverGroup: serverGroup, selectedServerIDs: $selectedServerIDs)
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
                    
                    if isUpdatingServerGroup {
                        ProgressViewWithBackground()
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
                    Button {
                        if selectedServerIDs != Set(serverGroup.serverIDs) {
                            isUpdatingServerGroup = true
                            Task {
                                do {
                                    let _ = try await RequestHandler.updateServerGroup(serverGroupID: serverGroup.serverGroupID, name: serverGroup.name, serverIDs: Array(selectedServerIDs))
                                    await dashboardViewModel.updateMannually()
                                    withAnimation {
                                        editMode = .inactive
                                    }
                                } catch {
                                    
                                }
                                isUpdatingServerGroup = false
                            }
                        }
                        else {
                            withAnimation {
                                editMode = .inactive
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
    
    struct ServerListView: View {
        @Environment(\.editMode) var editMode
        var dashboardViewModel: DashboardViewModel
        var serverGroup: ServerGroup
        var serverInGroup: [ServerData] {
            dashboardViewModel.servers.filter {
                serverGroup.serverIDs.contains($0.serverID)
            }
        }
        @Binding var selectedServerIDs: Set<Int64>
        
        var body: some View {
            if (!serverGroup.serverIDs.isEmpty && editMode?.wrappedValue == .inactive) || (!dashboardViewModel.servers.isEmpty && editMode?.wrappedValue == .active) {
                List(selection: $selectedServerIDs) {
                    if editMode?.wrappedValue == .inactive {
                        ForEach(serverInGroup) { server in
                            ServerTitle(server: server, lastUpdateTime: dashboardViewModel.lastUpdateTime)
                                .tag(server.serverID)
                        }
                    }
                    if editMode?.wrappedValue == .active {
                        ForEach(dashboardViewModel.servers) { server in
                            ServerTitle(server: server, lastUpdateTime: dashboardViewModel.lastUpdateTime)
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
}
