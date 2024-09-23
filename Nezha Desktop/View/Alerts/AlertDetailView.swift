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
    }
}
