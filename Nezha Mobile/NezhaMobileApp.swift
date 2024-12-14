//
//  Nezha_MobileApp.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import NezhaMobileData

@main
struct NezhaMobileApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var themeStore: ThemeStore = .init()
    var tabBarState: TabBarState = .init()
    var dashboardViewModel: DashboardViewModel = .init()
    var serviceViewModel: ServiceViewModel = .init()
    var serverGroupViewModel: ServerGroupViewModel = .init()
    var notificationViewModel: NotificationViewModel = .init()
    
    init() {
        NMCore.registerUserDefaults()
        NMCore.registerKeychain()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.createDataHandler, NezhaMobileData.shared.dataHandlerCreator())
                .environmentObject(appDelegate.notificationState)
                .environment(themeStore)
                .environment(tabBarState)
                .environment(dashboardViewModel)
                .environment(serverGroupViewModel)
                .environment(serviceViewModel)
                .environment(notificationViewModel)
                .onAppear {
                    appDelegate.tabBarState = tabBarState
                }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
    }
}
