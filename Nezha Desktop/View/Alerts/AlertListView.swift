//
//  AlertListView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/22/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct AlertListView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \ServerAlert.timestamp, order: .reverse) private var serverAlerts: [ServerAlert]
    @State private var searchText: String = ""
    
    private var filteredServerAlerts: [ServerAlert] {
        serverAlerts
            .filter { searchText.isEmpty || $0.title?.localizedCaseInsensitiveContains(searchText) == true }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if !serverAlerts.isEmpty {
                    Form {
                        ForEach(filteredServerAlerts) { serverAlert in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(serverAlert.title ?? "Untitled")
                                    if let timestamp = serverAlert.timestamp {
                                        Text(timestamp.formatted(date: .numeric, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Details") {
                                    openWindow(id: "alert-detail-view", value: serverAlert.id)
                                }
                                Button(role: .destructive) {
                                    Task {
                                        if let dataHandler = await createDataHandler() {
                                            _ = try await dataHandler.deleteServerAlert(id: serverAlert.persistentModelID)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .searchable(text: $searchText)
                    .navigationTitle("Alerts(\(serverAlerts.count))")
                }
                else {
                    ContentUnavailableView("No Alert", systemImage: "checkmark.circle.fill")
                }
            }
        }
    }
}
