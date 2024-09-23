//
//  AlertDetailView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/18/24.
//

import SwiftUI
import SwiftData
import NezhaMobileData

struct AlertDetailView: View {
    @Query var serverAlerts: [ServerAlert]
    var alertID: UUID?
    @State var time: Date?
    @State var title: String?
    @State var content: String?
    
    var body: some View {
        Form {
            if let time = time {
                Section("Time") {
                    Text(time.formatted(date: .long, time: .standard))
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Content") {
                Text(content ?? "")
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title ?? "")
        .onAppear {
            if let alertID {
                let alert = serverAlerts.first(where: { $0.id == alertID })
                time = alert?.timestamp
                title = alert?.title
                content = alert?.content
            }
        }
    }
}
