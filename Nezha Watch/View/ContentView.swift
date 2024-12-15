//
//  ContentView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @State private var isShowingOnboarding: Bool = false
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        Group {
            if isShowingOnboarding {
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
                        AddDashboardView(isShowingOnboarding: $isShowingOnboarding, dashboardViewModel: dashboardViewModel)
                    }
                }
                .padding()
            }
            else {
                ServerListView(dashboardViewModel: dashboardViewModel)
            }
        }
        .onAppear {
            NMCore.syncWithiCloud()
            
            if NMCore.isNezhaDashboardConfigured {
                dashboardViewModel.startMonitoring()
            } else {
                isShowingOnboarding = true
            }
        }
    }
}
