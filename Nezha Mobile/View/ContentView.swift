//
//  ContentView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dashboards: [Dashboard]
    @ObservedObject var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @State private var isShowingAddDashboardSheet: Bool = false
    @State private var isShowingSettingSheet: Bool = false

    var body: some View {
        NavigationStack {
            if dashboards.isEmpty {
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
                DashboardDetailView(dashboard: dashboards[0], dashboardViewModel: dashboardViewModel)
                    .toolbar {
                        ToolbarItem {
                            Button("Settings", systemImage: "gear") {
                                isShowingSettingSheet = true
                            }
                            .sheet(isPresented: $isShowingSettingSheet) {
                                SettingView(dashboardViewModel: dashboardViewModel)
                            }
                        }
                    }
            }
        }
    }


    private func deleteDashboards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(dashboards[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dashboard.self, inMemory: true)
}
