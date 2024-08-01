//
//  SettingView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var dashboards: [Dashboard]
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var color = "blue"
    @AppStorage("bgColor") private var bgColor = "blue"
    
    var body: some View {
        NavigationStack {
            Form {
                DashboardSettingView(dashboard: dashboards[0])
                
                Section("Theme") {
                    Picker("Background", selection: $color) {
                        Text("Blue").tag("blue")
                        Text("Green").tag("green")
                        Text("Yellow").tag("yellow")
                    }
                }
                
                Section("Aknowledge") {
                    NavigationLink(destination: {
                        Text("This project contains code by naiba/nezha which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                            .padding()
                    }) {
                        Text("LICENSE")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let dashboard = dashboards[0]
                        let connectionURLString: String = "\(dashboard.ssl ? "wss" : "ws")://\(dashboard.link)/ws"
                        dashboardViewModel.disconnect()
                        dashboardViewModel.connect(to: connectionURLString)
                        
                        bgColor = color
                        
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DashboardSettingView: View {
    @Bindable var dashboard: Dashboard
    
    var body: some View {
        Section("Dashboard") {
            TextField("Name", text: $dashboard.name)
            TextField("Link", text: $dashboard.link)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            Toggle("Use SSL", isOn: $dashboard.ssl)
        }
    }
}
