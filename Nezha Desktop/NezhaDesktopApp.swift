//
//  NezhaDesktopApp.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

@main
struct NezhaDesktopApp: App {
    @Bindable var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!
    
    init() {
        // Register UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")
        if let userDefaults {
            let defaultValues: [String: Any] = [
                "NMDashboardLink": "",
                "NMDashboardAPIToken": "",
                "NMLastModifyDate": 0
            ]
            userDefaults.register(defaults: defaultValues)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dashboardViewModel: dashboardViewModel)
        }
        .defaultSize(width: 1000, height: 500)
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
        
        WindowGroup("Map View", id: "map-view") {
            ServerMapView(servers: dashboardViewModel.servers)
        }
        
        WindowGroup("Server Details", for: Server.ID.self) { $serverID in
            if let serverID {
                ServerDetailView(dashboardViewModel: dashboardViewModel, serverID: serverID)
            }
        }
        .defaultSize(width: 800, height: 700)
        .commandsRemoved()
        
        Settings {
            SettingView(dashboardViewModel: dashboardViewModel)
        }
        
        menuBarExtra()
    }
    
    @SceneBuilder
    private func menuBarExtra() -> some Scene {
        @AppStorage("NMMenuBarEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var menuBarEnabled: Bool = false
        @AppStorage("NMMenuBarServerID", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) var menuBarServerID: String = ""
        
        MenuBarExtra(isInserted: $menuBarEnabled) {
            MenuBarView(dashboardViewModel: dashboardViewModel, serverID: menuBarServerID)
        } label: {
            if dashboardViewModel.loadingState == .loaded {
                HStack {
                    let image: NSImage = {
                        let ratio = $0.size.height / $0.size.width
                        $0.size.height = 15
                        $0.size.width = 15 / ratio
                        return $0
                    }(NSImage(named: "NezhaLogo")!)
                    Image(nsImage: image)
                    
                    if let server = dashboardViewModel.servers.first(where: { String($0.id) == menuBarServerID }) {
                        let totalCore = Double(getCore(server.host.cpu) ?? 1)
                        let loadPressure = server.status.load15 / totalCore
                        Text("\(loadPressure * 100, specifier: "%.0f")%")
                    }
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
