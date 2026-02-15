//
//  SettingView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI
import NezhaMobileData

struct SettingView: View {
    @Environment(\.createDataHandler) private var createDataHandler
    @AppStorage("NMMenuBarEnabled", store: NMCore.userDefaults) var menuBarEnabled: Bool = true
    
    var body: some View {
        TabView {
            DashboardSettingsView()
            
            ThemeSettingsView()
            
            Form {
                Toggle("Enable Menu Bar", isOn: $menuBarEnabled)
            }
            .padding()
            .frame(width: 600, height: 400)
            .tabItem {
                Label("Menu Bar", systemImage: "menubar.rectangle")
            }
            
            Form {
                let pushNotificationsToken = NMCore.userDefaults.string(forKey: "NMMacPushNotificationsToken")!
                if pushNotificationsToken != "" {
                    Button("Copy Push Notifications Token") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(pushNotificationsToken, forType: .string)
                    }
                }
                else {
                    Text("Push Notifications Not Available")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(width: 600, height: 400)
            .tabItem {
                Label("Notifications", systemImage: "app.badge")
            }
        }
    }
}
