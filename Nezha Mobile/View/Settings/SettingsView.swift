//
//  SettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import UserNotifications
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    @State var isPresentedAsSheet: Bool = false
    @State private var isShowingChangeThemeSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    NavigationLink("Dashboard Settings") {
                        DashboardSettingsView()
                    }
                }
                
                Section("Theme") {
                    Button("Select Theme") {
                        isShowingChangeThemeSheet.toggle()
                    }
                    .sheet(isPresented: $isShowingChangeThemeSheet) {
                        ChangeThemeView(isShowingChangeThemeSheet: $isShowingChangeThemeSheet)
                            .presentationDetents([.height(400)])
                            .presentationBackground(.clear)
                    }
                    
                    NavigationLink("Advanced Customization") {
                        AdvancedCustomizationView()
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
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
            }
            .onAppear {
                withAnimation {
                    tabBarState.isSettingsViewVisible = true
                }
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isSettingsViewVisible = false
                }
            }
        }
    }
}
