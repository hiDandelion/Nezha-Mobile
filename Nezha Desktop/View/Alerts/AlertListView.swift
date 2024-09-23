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
                            NavigationLink(destination: AlertDetailView(time: serverAlert.timestamp, title: serverAlert.title, content: serverAlert.content)) {
                                VStack(alignment: .leading) {
                                    Text(serverAlert.title ?? "Untitled")
                                    if let timestamp = serverAlert.timestamp {
                                        Text(timestamp.formatted(date: .numeric, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        let createDataHandler = createDataHandler
                                        Task {
                                            if let dataHandler = await createDataHandler() {
                                                _ = try await dataHandler.deleteServerAlert(id: serverAlert.persistentModelID)
                                            }
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
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
