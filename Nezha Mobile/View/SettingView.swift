//
//  SettingView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import WidgetKit

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var isNeedReconnection: Bool = false {
        didSet {
            DispatchQueue.main.async {
                dashboardViewModel.stopMonitoring()
            }
        }
    }
    @State private var isShowingChangeThemeSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .onChange(of: dashboardLink) {
                            DispatchQueue.main.async {
                                isNeedReconnection = true
                            }
                        }
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .onChange(of: dashboardAPIToken) {
                            DispatchQueue.main.async {
                                isNeedReconnection = true
                            }
                        }
                }
                
                Section("Theme") {
                    Button("Change Theme") {
                        isShowingChangeThemeSheet.toggle()
                    }
                    .sheet(isPresented: $isShowingChangeThemeSheet) {
                        ChangeThemeView()
                            .presentationDetents([.height(410)])
                            .presentationBackground(.clear)
                    }
                }
                
                Section("Help") {
                    Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                    Link("How to install Nezha Dashboard", destination: URL(string: "https://nezha.wiki")!)
                }
                
                Section("About") {
                    Link("Original Project Nezha", destination: URL(string: "https://github.com/naiba/nezha")!)
                    NavigationLink(destination: {
                        Form {
                            Text("This project is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                            Text("Part of this project is related to Project Nezha by naiba which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                        }
                        .navigationTitle("LICENSE")
                    }) {
                        Text("LICENSE")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !dashboardViewModel.isMonitoringEnabled {
                            dashboardViewModel.startMonitoring()
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if !dashboardViewModel.isMonitoringEnabled {
                            if let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") {
                                userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                                userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                                dashboardViewModel.startMonitoring()
                            }
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
