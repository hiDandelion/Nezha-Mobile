//
//  ContentView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @Bindable var dashboardViewModel: DashboardViewModel
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
                    HomeView(dashboardLink: dashboardLink, dashboardAPIToken: dashboardAPIToken, dashboardViewModel: dashboardViewModel)
                }
            }
        }
        .onAppear {
            syncWithiCloud()
        }
    }
}
