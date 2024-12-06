//
//  ContentView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(DashboardViewModel.self) private var dashboardViewModel
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
                        AddDashboardView()
                    }
                }
                .padding()
            }
            else {
                HomeView()
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
