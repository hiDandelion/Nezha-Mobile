//
//  SettingView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var menuBarEnabled: Bool = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.bool(forKey: "NMMenuBarEnabled")
    @State private var menuBarServerID: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMMenuBarServerID") ?? ""
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
                TextField("Server ID", text: $menuBarServerID)
                    .autocorrectionDisabled()
                    .disabled(!menuBarEnabled)
                Button("Save") {
                    userDefaults.set(menuBarEnabled, forKey: "NMMenuBarEnabled")
                    userDefaults.set(menuBarServerID, forKey: "NMMenuBarServerID")
                    isShowSuccessfullySavedAlert = true
                }
                .disabled(menuBarServerID == "")
            }
            .padding()
            .tabItem {
                Label("Menu Bar", systemImage: "menubar.rectangle")
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
