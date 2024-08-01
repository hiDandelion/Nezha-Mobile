//
//  AddDashboardView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct AddDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @State private var link: String = ""
    @State private var ssl: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard Info") {
                    TextField("Name", text: $name)
                    TextField("Link", text: $link)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    Toggle("Use SSL", isOn: $ssl)
                }
                
                Section("Help") {
                    Link("User Guide", destination: URL(string: "https://nezha.wiki")!)
                    Button("Use Demo") {
                        name = "Demo Dashboard"
                        link = "server.hidandelion.com"
                        addDashboard()
                    }
                }
            }
            .navigationTitle("Add Dashboard")
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        addDashboard()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addDashboard() {
        modelContext.insert(Dashboard(name: name, link: link, ssl: ssl))
    }
}
