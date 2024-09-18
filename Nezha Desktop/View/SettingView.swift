//
//  SettingView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct SettingView: View {
    @Bindable var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    @AppStorage("NMMenuBarEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var menuBarEnabled: Bool = true
    @State private var isShowSuccessfullySavedAlert: Bool = false
    
    var body: some View {
        TabView {
            Form {
                Section {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                } header: {
                    Text("Dashboard Info")
                } footer: {
                    Text("SSL must be enabled. Dashboard Link Example: server.hidandelion.com")
                }
                Button("Save") {
                    userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                    userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                    userDefaults.set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    NSUbiquitousKeyValueStore().set(dashboardLink, forKey: "NMDashboardLink")
                    NSUbiquitousKeyValueStore().set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                    NSUbiquitousKeyValueStore().set(Int(Date().timeIntervalSince1970), forKey: "NMLastModifyDate")
                    isShowSuccessfullySavedAlert = true
                    dashboardViewModel.startMonitoring()
                }
                .disabled(dashboardLink == "" || dashboardAPIToken == "")
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            Form {
                Toggle("Enable Menu Bar", isOn: $menuBarEnabled)
            }
            .padding()
            .tabItem {
                Label("Menu Bar", systemImage: "menubar.rectangle")
            }
            
            Form {
                let pushNotificationsToken = userDefaults.string(forKey: "NMMacPushNotificationsToken")!
                if pushNotificationsToken != "" {
                    ShareLink(item: pushNotificationsToken) {
                        Text("Share Push Notifications Token")
                    }
                }
                else {
                    Text("Push Notifications Not Available")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .tabItem {
                Label("Notifications", systemImage: "app.badge")
            }
        }
        .frame(width: 600, height: 400)
        .alert("Successfully Saved", isPresented: $isShowSuccessfullySavedAlert) {
            Button("OK", role: .cancel) {
                isShowSuccessfullySavedAlert = false
            }
        }
    }
}
