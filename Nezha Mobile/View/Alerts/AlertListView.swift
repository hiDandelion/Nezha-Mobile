//
//  AlertListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/9/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct AlertListView: View {
    @Environment(\.createDataHandler) private var createDataHandler
    @Environment(NMState.self) var state
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    @State private var isShowingDeleteAllConfirmationDialog: Bool = false
    
    var body: some View {
        NavigationStack(path: Bindable(state).pathAlerts) {
            Group {
                if !serverAlerts.isEmpty {
                    List {
                        ForEach(serverAlerts) { serverAlert in
                            NavigationLink(value: serverAlert) {
                                VStack(alignment: .leading) {
                                    Text(nameCanBeUntitled(serverAlert.title))
                                    Text(serverAlert.content ?? "No Content")
                                        .font(.footnote)
                                    if let timestamp = serverAlert.timestamp {
                                        Text(timestamp.formatted(date: .numeric, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .lineLimit(1)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Delete", role: .destructive) {
                                        deleteAlert(serverAlert: serverAlert)
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteAlert(serverAlert: serverAlert)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Alerts")
                    .toolbar {
                        toolbarMenu
                    }
                    .safeAreaInset(edge: .bottom) {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 50)
                    }
                }
                else {
                    ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
#if DEBUG
                        .toolbar {
                            addAlertButton
                        }
                    
#endif
                }
            }
            .navigationDestination(for: ServerAlert.self) { alert in
                AlertDetailView(alert: alert)
            }
            .confirmationDialog(
                Text("Delete All Alerts"),
                isPresented: $isShowingDeleteAllConfirmationDialog,
                actions: {
                    Button("Delete", role: .destructive) {
                        let createDataHandler = createDataHandler
                        Task {
                            if let dataHandler = await createDataHandler() {
                                _ = try await dataHandler.deleteAllServerAlerts()
                            }
                        }
                    }
                },
                message: {
                    Text("All alerts will be deleted. Are you sure?")
                }
            )
        }
    }
    
    private var toolbarMenu: some View {
        Menu {
            Button(role: .destructive) {
                isShowingDeleteAllConfirmationDialog = true
            } label: {
                Label("Delete All", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    private func deleteAlert(serverAlert: ServerAlert) {
        let createDataHandler = createDataHandler
        Task {
            if let dataHandler = await createDataHandler() {
                _ = try await dataHandler.deleteServerAlert(id: serverAlert.persistentModelID)
            }
        }
    }
    
#if DEBUG
    private var addAlertButton: some View {
            Button {
                let createDataHandler = createDataHandler
                Task {
                    if let dataHandler = await createDataHandler() {
                        _ = try await dataHandler.newServerAlert(uuid: UUID(), timestamp: Date(), title: "New Alert", content: "Alert Content")
                    }
                }
            } label: {
                Label("Add Alert", systemImage: "plus")
            }
    }
#endif
}
