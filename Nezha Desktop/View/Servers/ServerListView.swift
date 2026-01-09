//
//  ServerListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/25/24.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    @State private var backgroundImage: NSImage?
    @State private var sortIndicator: SortIndicator = .index
    @State private var sortOrder: SortOrder = .descending
    @State private var searchText: String = ""
    var selectedServerGroup: ServerGroup?
    
    @State private var isShowAddServerSheet: Bool = false
    
    @State private var isShowRenameServerAlert: Bool = false
    @State private var serverToRename: ServerData?
    @State private var newNameOfServer: String = ""
    
    @State private var isShowDeleteServerAlert: Bool = false
    @State private var serverToDelete: ServerData?
    
    private var filteredServers: [ServerData] {
        state.servers
            .sorted {
                switch sortIndicator {
                case .index:
                    if $0.displayIndex == $1.displayIndex {
                        return sortOrder == .ascending ? $0.serverID < $1.serverID : $0.serverID > $1.serverID
                    }
                    return $0.displayIndex > $1.displayIndex
                case .uptime:
                    return sortOrder == .ascending ? $0.status.uptime < $1.status.uptime : $0.status.uptime > $1.status.uptime
                case .cpu:
                    return sortOrder == .ascending ? $0.status.cpuUsed < $1.status.cpuUsed : $0.status.cpuUsed > $1.status.cpuUsed
                case .memory:
                    let memoryUsage0 = ($0.host.memoryTotal == 0 ? 0 : Double($0.status.memoryUsed) / Double($0.host.memoryTotal))
                    let memoryUsage1 = ($1.host.memoryTotal == 0 ? 0 : Double($1.status.memoryUsed) / Double($1.host.memoryTotal))
                    return sortOrder == .ascending ? memoryUsage0 < memoryUsage1 : memoryUsage0 > memoryUsage1
                case .disk:
                    let diskUsage0 = ($0.host.diskTotal == 0 ? 0 : Double($0.status.diskUsed) / Double($0.host.diskTotal))
                    let diskUsage1 = ($1.host.diskTotal == 0 ? 0 : Double($1.status.diskUsed) / Double($1.host.diskTotal))
                    return sortOrder == .ascending ? diskUsage0 < diskUsage1 : diskUsage0 > diskUsage1
                case .send:
                    return sortOrder == .ascending ? $0.status.networkOut < $1.status.networkOut : $0.status.networkOut > $1.status.networkOut
                case .receive:
                    return sortOrder == .ascending ? $0.status.networkIn < $1.status.networkIn : $0.status.networkIn > $1.status.networkIn
                }
            }
            .filter {
                if let selectedServerGroup {
                    return selectedServerGroup.serverIDs.contains($0.serverID)
                }
                else {
                    return true
                }
            }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 320, maximum: 450))]
    
    var body: some View {
        NavigationStack(path: Bindable(state).pathServers) {
            ZStack {
                background
                    .zIndex(0)
                
                dashboard
                    .zIndex(1)
            }
            .navigationDestination(for: ServerData.self) { server in
                ServerDetailView(id: server.id)
            }
        }
        .sheet(isPresented: $isShowAddServerSheet) {
            AddServerView()
        }
        .alert("Rename Server", isPresented: $isShowRenameServerAlert) {
            TextField("Name", text: $newNameOfServer)
            Button("OK") {
                Task {
                    let result = try? await RequestHandler.renameServer(serverID: serverToRename!.serverID, to: newNameOfServer)
                    if result?.success == true {
                        await state.refreshServerAndServerGroup()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a new name for the server.")
        }
        .alert("Delete Server", isPresented: $isShowDeleteServerAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    let result = try? await RequestHandler.deleteServer(serverID: serverToRename!.serverID)
                    if result?.success == true {
                        await state.refreshServerAndServerGroup()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You are about to delete this server. Are you sure?")
        }
        .onAppear {
            let backgroundPhotoData = NMCore.userDefaults.data(forKey: "NMBackgroundPhotoData")
            if let backgroundPhotoData {
                backgroundImage = NSImage(data: backgroundPhotoData)
            }
            else {
                backgroundImage = nil
            }
        }
    }
    
    private var background: some View {
        Group {
            if let backgroundImage {
                GeometryReader { proxy in
                    Image(nsImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: proxy.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
            }
            else {
                theme.themeBackgroundColor(scheme: scheme)
                    .ignoresSafeArea()
            }
        }
    }
    
    private var dashboard: some View {
        Group {
            ScrollView {
                serverList
            }
            .navigationTitle("Servers")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem {
                    mapButton
                }
                if #available(macOS 26.0, *) {
                    ToolbarSpacer(.fixed)
                }
                ToolbarItem {
                    addButton
                }
                if #available(macOS 26.0, *) {
                    ToolbarSpacer(.fixed)
                }
                ToolbarItem {
                    moreButton
                }
            }
            .loadingState(loadingState: state.dashboardLoadingState) {
                state.loadDashboard()
            }
        }
    }
    
    private var addButton: some View {
        Button("Add Server", systemImage: "plus") {
            isShowAddServerSheet = true
        }
    }
    
    private var mapButton: some View {
        Button("Map View", systemImage: "map") {
            openWindow(id: "map-view")
        }
    }
    
    private var moreButton: some View {
        Menu("More", systemImage: "ellipsis") {
            Picker("Sort", selection: Binding(get: {
                sortIndicator
            }, set: { newValue in
                if sortIndicator == newValue {
                    switch(sortOrder) {
                    case .ascending:
                        sortOrder = .descending
                    case .descending:
                        sortOrder = .ascending
                    }
                }
                else {
                    sortIndicator = newValue
                }
            })) {
                ForEach(SortIndicator.allCases, id: \.self) { sortIndicator in
                    Button {
                        
                    } label: {
                        Text(sortIndicator.title)
                        if self.sortIndicator == sortIndicator && sortIndicator != .index {
                            Text(sortOrder.title)
                        }
                    }
                    .tag(sortIndicator)
                }
            }
        }
    }
    
    private var serverList: some View {
        Group {
            if !state.servers.isEmpty {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredServers) { server in
                        ServerCardView(server: server, lastUpdateTime: state.dashboardLastUpdateTime)
                            .onTapGesture {
                                openWindow(id: "server-detail-view", value: server.id)
                            }
                            .contextMenu {
                                ControlGroup("Copy IP", systemImage: "document.on.document") {
                                    if server.ipv4 != "" {
                                        Button {
#if os(macOS)
                                            NSPasteboard.general.clearContents()
                                            NSPasteboard.general.setString(server.ipv4, forType: .string)
#endif
                                        } label: {
                                            Label("Copy IPv4", systemImage: "4.circle")
                                        }
                                    }
                                    if server.ipv6 != "" {
                                        Button {
#if os(macOS)
                                            NSPasteboard.general.clearContents()
                                            NSPasteboard.general.setString(server.ipv6, forType: .string)
#endif
                                        } label: {
                                            Label("Copy IPv6", systemImage: "6.circle")
                                        }
                                    }
                                }
                                Button {
                                    serverToRename = server
                                    newNameOfServer = server.name
                                    isShowRenameServerAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    serverToDelete = server
                                    isShowDeleteServerAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
            }
            else {
                ContentUnavailableView("No Server", systemImage: "square.stack.3d.up.slash.fill")
            }
        }
    }
}
