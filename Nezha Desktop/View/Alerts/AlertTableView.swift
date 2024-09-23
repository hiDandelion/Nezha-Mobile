//
//  AlertTableView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/22/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct AlertTableView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    @State private var searchText: String = ""
    @State private var selectedAlerts: Set<ServerAlert.ID> = Set<ServerAlert.ID>()
    
    private var filteredServerAlerts: [ServerAlert] {
        serverAlerts
            .filter { searchText.isEmpty || $0.title?.localizedCaseInsensitiveContains(searchText) == true }
    }
    
    var body: some View {
        Group {
            if !serverAlerts.isEmpty {
                Table(of: ServerAlert.self, selection: $selectedAlerts) {
                    TableColumn("Title") { alert in
                        Text(alert.title ?? "Untitled")
                    }
                    TableColumn("Time") { alert in
                        if let time = alert.timestamp {
                            Text(time.formatted(date: .long, time: .standard))
                                .foregroundStyle(.secondary)
                        }
                    }
                } rows: {
                    ForEach(filteredServerAlerts, id: \.id) { alert in
                        TableRow(alert)
                            .contextMenu {
                                Button(role: .destructive) {
                                    let createDataHandler = createDataHandler
                                    Task {
                                        if let dataHandler = await createDataHandler() {
                                            _ = try await dataHandler.deleteServerAlert(id: alert.persistentModelID)
                                        }
                                    }
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                }
                .contextMenu(forSelectionType: ServerAlert.ID.self) { items in
                    
                } primaryAction: { alertIDs in
                    for alertID in alertIDs {
                        openWindow(id: "alert-detail-view", value: alertID)
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Alerts(\(serverAlerts.count))")
            }
            else {
                ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
            }
        }
    }
}
