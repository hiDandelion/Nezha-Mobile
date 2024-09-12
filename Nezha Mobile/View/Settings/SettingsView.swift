//
//  SettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) var themeStore
    @Environment(TabBarState.self) var tabBarState
    var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State var isPresentedAsSheet: Bool = false
    @State private var isShowingChangeThemeSheet: Bool = false
    @State private var isShowCopyTokenSuccessAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    NavigationLink("Dashboard Settings") {
                        DashboardSettingsView(dashboardViewModel: dashboardViewModel)
                    }
                }
                
                Section("SSH") {
                    NavigationLink("Identities") {
                        IdentityListView()
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
                
                Section("Notifications") {
                    let pushNotificationsToken = userDefaults.string(forKey: "NMPushNotificationsToken")!
                    if pushNotificationsToken != "" {
                        Button("Copy Push Notifications Token") {
                            UIPasteboard.general.setValue(pushNotificationsToken, forPasteboardType: UTType.plainText.identifier)
                            isShowCopyTokenSuccessAlert = true
                        }
                        .alert("Copied", isPresented: $isShowCopyTokenSuccessAlert) {
                            Button("OK", role: .cancel) {
                                isShowCopyTokenSuccessAlert = false
                            }
                        }
                    }
                    else {
                        Text("Push Notifications Not Available")
                            .foregroundStyle(.secondary)
                    }
                    
                    if #available(iOS 17.2, *) {
                        let pushToStartToken = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMPushToStartToken")!
                        if pushToStartToken != "" {
                            Button("Copy Push To Start Token") {
                                UIPasteboard.general.setValue(pushToStartToken, forPasteboardType: UTType.plainText.identifier)
                                isShowCopyTokenSuccessAlert = true
                            }
                            .alert("Copied", isPresented: $isShowCopyTokenSuccessAlert) {
                                Button("OK", role: .cancel) {
                                    isShowCopyTokenSuccessAlert = false
                                }
                            }
                        }
                        else {
                            Text("Live Activity Not Available")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Help") {
                    Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                }
                
                Section("About") {
                    NavigationLink(destination: {
                        AboutView()
                    }) {
                        Text("About")
                    }
                }
            }
            .contentMargins(.bottom, 50)
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
