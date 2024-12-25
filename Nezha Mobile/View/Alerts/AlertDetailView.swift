//
//  AlertDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/12/24.
//

import SwiftUI
import NezhaMobileData

struct AlertDetailView: View {
    @Environment(NMState.self) var state
    let alert: ServerAlert
    
    var body: some View {
        Form {
            if let time = alert.timestamp {
                Section("Time") {
                    Text(time.formatted(date: .long, time: .standard))
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Content") {
                Text(alert.content ?? "")
            }
        }
        .navigationTitle(nameCanBeUntitled(alert.title))
    }
}
