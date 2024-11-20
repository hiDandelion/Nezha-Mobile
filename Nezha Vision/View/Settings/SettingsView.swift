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
    var dashboardViewModel: DashboardViewModel
    @State var isPresentedAsSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    NavigationLink("Dashboard Settings") {
                        DashboardSettingsView(dashboardViewModel: dashboardViewModel)
                    }
                }
                
                Section("Help") {
                    Link("User Guide", destination: NMCore.userGuideURL)
                }
                
                Section("About") {
                    Button("Rate Us") {
                        requestReview()
                    }
                    
                    NavigationLink(destination: {
                        NMUI.AcknowledgmentView()
                    }) {
                        Text("Acknowledgments")
                    }
                }
            }
            .navigationTitle("Settings")
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
