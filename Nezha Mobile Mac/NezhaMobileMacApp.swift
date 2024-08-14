//
//  NezhaMobileMacApp.swift
//  Nezha Mobile Mac
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

@main
struct NezhaMobileMacApp: App {
    @ObservedObject var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMLastModifyDate": 0,
                "NMPushNotificationsToken": "",
                "NMPushToStartToken": ""
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dashboardViewModel: dashboardViewModel)
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.help) {
                Link("User Guide", destination: URL(string: "https://nezha.wiki/case/case6.html")!)
                NavigationLink(destination: {
                    Form {
                        Text("This project is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                        Text("Part of this project is related to Project Nezha by naiba which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                        Text("Intel logo is a trademark of Intel Corporation. AMD logo is a trademark of Advanced Micro Devices, Inc. ARM logo is a trademark of Arm Limited. Apple logo, macOS logo are trademarks of Apple Inc.")
                    }
                    .navigationTitle("About")
                    .padding()
                }) {
                    Text("About")
                }
            }
        }
        
        WindowGroup("Server Detail", for: Server.ID.self) { $serverID in
            if let server = dashboardViewModel.servers.first(where: { $0.id == serverID }) {
                ServerDetailView(server: server)
            }
        }
        .defaultSize(width: 800, height: 700)
        
        Settings {
            SettingView(dashboardViewModel: dashboardViewModel)
        }
    }
}
