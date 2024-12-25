//
//  SettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(NMState.self) private var state
    @State var isPresentedAsSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(value: "dashboard-settings") {
                        Text("Dashboard Settings")
                    }
                }
                
                Section("About") {
                    Link("User Guide", destination: NMCore.userGuideURL)
                    Button("Rate Us") {
                        requestReview()
                    }
                    
                    NavigationLink(value: "acknowledgments") {
                        Text("Acknowledgments")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: String.self) { target in
                switch(target) {
                case "dashboard-settings":
                    DashboardSettingsView()
                case "acknowledgments":
                    NMUI.AcknowledgmentView()
                default:
                    EmptyView()
                }
            }
            .toolbar {
                if isPresentedAsSheet {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
