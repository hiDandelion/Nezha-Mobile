//
//  SettingView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var isShowSaveDashboardSuccessAlert: Bool = false
    @State private var isShowingChangeThemeSheet: Bool = false
    @Binding var backgroundImage: UIImage?
    @ObservedObject var themeStore: ThemeStore
    @State private var isShowCopyTokenSuccessAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    Button("Save & Reconnect") {
                        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
                        userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                        userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                        userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                        NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
                        NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                        NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                        dashboardViewModel.startMonitoring()
                        isShowSaveDashboardSuccessAlert = true
                    }
                    .alert("Successfully Saved", isPresented: $isShowSaveDashboardSuccessAlert) {
                        Button("OK", role: .cancel) {
                            isShowSaveDashboardSuccessAlert = false
                        }
                    }
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("SSL must be enabled. Dashboard Link Example: server.hidandelion.com")
                }
                
                Section("Theme") {
                    Button("Select Theme") {
                        isShowingChangeThemeSheet.toggle()
                    }
                    .sheet(isPresented: $isShowingChangeThemeSheet) {
                        if #available(iOS 16.4, *) {
                            ChangeThemeView(isShowingChangeThemeSheet: $isShowingChangeThemeSheet)
                                .presentationDetents([.height(400)])
                                .presentationBackground(.clear)
                        }
                        else {
                            ChangeThemeView(isShowingChangeThemeSheet: $isShowingChangeThemeSheet)
                                .presentationDetents([.height(400)])
                                // presentationBackground ×
                        }
                    }
                    
                    NavigationLink("Advanced Customization") {
                        AdvancedCustomizationView(backgroundImage: $backgroundImage, themeStore: themeStore)
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
                        Form {
                            Text("This project is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                            Text("Part of this project is related to Project Nezha by naiba which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                            Text("Intel logo is a trademark of Intel Corporation. AMD logo is a trademark of Advanced Micro Devices, Inc. ARM logo is a trademark of Arm Limited. Apple logo, macOS logo are trademarks of Apple Inc.")
                        }
                        .navigationTitle("About")
                    }) {
                        Text("About")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
