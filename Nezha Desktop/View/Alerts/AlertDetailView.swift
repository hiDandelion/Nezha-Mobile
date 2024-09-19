//
//  AlertDetailView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/18/24.
//

import SwiftUI

struct AlertDetailView: View {
    let time: Date?
    let title: String?
    let content: String?
    
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
    }
}
