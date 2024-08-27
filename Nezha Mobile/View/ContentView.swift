//
//  ContentView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notificationState: NotificationState
    @State private var shouldNavigateToServerDetailView: Bool = false
    @State private var incomingURLServerID: Int?
    @ObservedObject var themeStore: ThemeStore = ThemeStore()
    @ObservedObject var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @AppStorage("NMDashboardLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardLink: String = ""
    @AppStorage("NMDashboardAPIToken", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardAPIToken: String = ""
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if dashboardLink == "" || dashboardAPIToken == "" || isShowingAddDashboardSheet {
                    VStack {
                        Text("Start your journey with Nezha Mobile")
                            .font(.title3)
                            .frame(alignment: .center)
                        Button("Start", systemImage: "arrow.right.circle") {
                            isShowingAddDashboardSheet = true
                        }
                        .font(.headline)
                        .padding(.top, 20)
                        .sheet(isPresented: $isShowingAddDashboardSheet) {
                            AddDashboardView(dashboardViewModel: dashboardViewModel)
                        }
                    }
                    .padding()
                }
                else {
                    DashboardView(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                }
            }
            .navigationDestination(isPresented: $notificationState.shouldNavigateToNotificationView) {
                NotificationDetailView()
            }
            .navigationDestination(isPresented: $shouldNavigateToServerDetailView) {
                if let incomingURLServerID {
                    ServerDetailView(serverID: incomingURLServerID, dashboardViewModel: dashboardViewModel, themeStore: themeStore)
                }
            }
            .onOpenURL { url in
                _ = debugLog("Incoming Link Info - App was opened via URL: \(url)")
                handleIncomingURL(url)
            }
        }
        .onAppear {
            syncWithiCloud()
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nezha" else {
            _ = debugLog("Incoming Link Error - Invalid Scheme")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            _ = debugLog("Incoming Link Error - Invalid URL")
            return
        }
        
        guard let action = components.host, action == "server-details" else {
            _ = debugLog("Incoming Link Error - Unknown action")
            return
        }
        
        guard let serverID = components.queryItems?.first(where: { $0.name == "serverID" })?.value else {
            _ = debugLog("Incoming Link Error - Server ID not found")
            return
        }
        
        incomingURLServerID = Int(serverID)
        shouldNavigateToServerDetailView = true
    }
}
