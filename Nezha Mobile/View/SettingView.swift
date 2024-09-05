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
    var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var isShowingChangeThemeSheet: Bool = false
    @Binding var backgroundImage: UIImage?
    var themeStore: ThemeStore
    @State private var isShowCopyTokenSuccessAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    NavigationLink("Dashboard Settings") {
                        DashboardSettingView(dashboardViewModel: dashboardViewModel)
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
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("This project is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                                Text("Part of this project is related to Project naiba/nezha which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                                Text("This project has dependency hyperoslo/Cache which is subject to\nMIT License")
                                Text("This project has dependency apple/swift-nio-ssh which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                                Text("This project has dependency Lakr233/XTerminalUI which is subject to\nMIT License")
                                Text("Intel logo is a trademark of Intel Corporation. AMD logo is a trademark of Advanced Micro Devices, Inc. ARM logo is a trademark of Arm Limited. Windows logo is a trademark of Microsoft Inc. Apple logo, macOS logo are trademarks of Apple Inc.")
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .navigationTitle("About")
                        .navigationBarTitleDisplayMode(.inline)
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
