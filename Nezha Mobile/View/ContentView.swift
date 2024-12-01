//
//  ContentView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(ThemeStore.self) var themeStore
    @AppStorage(NMCore.NMDashboardLink, store: NMCore.userDefaults) private var dashboardLink: String = ""
    @AppStorage(NMCore.NMDashboardUsername, store: NMCore.userDefaults) private var dashboardUsername: String = ""
    @State private var isShowingAddDashboardSheet: Bool = false
    
    var body: some View {
        if dashboardLink == "" || dashboardUsername == "" || isShowingAddDashboardSheet {
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
            MainTabView()
        }
    }
}
