//
//  SettingView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var dashboards: [Dashboard]
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var requireReconnection: Bool = false
    @AppStorage("bgColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var bgColor: String = "blue"
    @AppStorage("widgetDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetDashboardLink: String = ""
    @AppStorage("widgetAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetAPIToken: String = ""
    @AppStorage("widgetServerID", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetServerID: String = ""
    @State private var isShowingApplyConfigurationSucceedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                DashboardSettingView(dashboard: dashboards[0], requireReconnection: $requireReconnection)
                
                Section("Theme") {
                    Picker("Background", selection: $bgColor) {
                        Text("Blue").tag("blue")
                        Text("Green").tag("green")
                        Text("Yellow").tag("yellow")
                    }
                }
                
                Section("Widget") {
                    NavigationLink {
                        NavigationStack {
                            Form {
                                Section {
                                    TextField("Dashboard Link", text: $widgetDashboardLink)
                                        .autocorrectionDisabled()
                                        .autocapitalization(.none)
                                    TextField("API Token", text: $widgetAPIToken)
                                        .autocorrectionDisabled()
                                        .autocapitalization(.none)
                                    TextField("Server ID", text: $widgetServerID)
                                        .autocorrectionDisabled()
                                        .autocapitalization(.none)
                                } header: {
                                    Text("Configurations")
                                } footer: {
                                    Text("For security concerns, you must enable SSL before using API tokens.")
                                }
                                
                                Section("Deploy") {
                                    Button("Apply configuration now") {
                                        WidgetCenter.shared.reloadAllTimelines()
                                        isShowingApplyConfigurationSucceedAlert = true
                                    }
                                }
                            }
                            .navigationTitle("Configure Widget")
                            .alert("Success", isPresented: $isShowingApplyConfigurationSucceedAlert, actions: {
                                Button("Done") {
                                    isShowingApplyConfigurationSucceedAlert = false
                                }
                            }, message: {
                                Text("Configuration has been applied.")
                            })
                        }
                    } label: {
                        Text("Configure Widget")
                    }
                }
                
                Section("Aknowledge") {
                    Link("How to install Nezha Dashboard", destination: URL(string: "https://nezha.wiki")!)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            if requireReconnection {
                let dashboard = dashboards[0]
                let connectionURLString: String = "\(dashboard.ssl ? "wss" : "ws")://\(dashboard.link)/ws"
                dashboardViewModel.disconnect()
                dashboardViewModel.connect(to: connectionURLString)
            }
        }
    }
}

struct DashboardSettingView: View {
    @Bindable var dashboard: Dashboard
    @Binding var requireReconnection: Bool
    
    var body: some View {
        Section("Dashboard") {
            TextField("Name", text: $dashboard.name)
            TextField("Link", text: $dashboard.link)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .onChange(of: dashboard.link) {
                    requireReconnection = true
                }
            Toggle("Use SSL", isOn: $dashboard.ssl)
                .onChange(of: dashboard.ssl) {
                    requireReconnection = true
                }
        }
    }
}
