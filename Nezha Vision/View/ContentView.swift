//
//  ContentView.swift
//  Nezha Vision
//
//  Created by Junhui Lou on 10/22/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(NMState.self) private var state
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
                        AddDashboardView(isShowingOnboarding: $isShowingOnboarding)
                    }
                }
                .padding()
            }
            else {
                MainTabView()
            }
        }
        .onAppear {
            NMCore.syncWithiCloud()
            
            if NMCore.isNezhaDashboardConfigured {
                state.loadDashboard()
            } else {
                isShowingOnboarding = true
            }
        }
    }
}
