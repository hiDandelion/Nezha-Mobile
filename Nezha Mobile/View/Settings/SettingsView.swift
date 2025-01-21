//
//  SettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import UserNotifications
import StoreKit
import WishKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(NMTheme.self) var theme
    @Environment(NMState.self) var state
    @State var isPresentedAsSheet: Bool = false
    @State private var isShowingChangeThemeSheet: Bool = false
    
    var body: some View {
        NavigationStack(path: Bindable(state).path) {
            Form {
                Section {
                    NavigationLink(value: "dashboard-settings") {
                        Text("Dashboard Settings")
                    }
                }
                
                Section {
                    NavigationLink(value: "theme-settings") {
                        Text("Theme Settings")
                    }
                }
                
                Section("About") {
                    Link("User Guide", destination: NMCore.userGuideURL)
                    Button("Rate Us") {
                        requestReview()
                    }
                    NavigationLink(value: "feature-suggestions") {
                        Text("Feature Suggestions")
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
                case "theme-settings":
                    ThemeSettingsView()
                case "feature-suggestions":
                    WishKit.FeedbackListView()
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
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
        }
    }
}
