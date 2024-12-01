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
    var serverGroupViewModel: ServerGroupViewModel = .init()
    var notificationViewModel: NotificationViewModel = .init()
    
    init() {
        NMCore.registerUserDefaults()
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
                .environment(notificationViewModel)
                .onAppear {
                    appDelegate.tabBarState = tabBarState
                    NMCore.syncWithiCloud()
                }
        }
        .modelContainer(NezhaMobileData.shared.modelContainer)
    }
}
