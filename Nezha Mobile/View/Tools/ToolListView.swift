//
//  ToolListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
//

import SwiftUI

struct ToolListView: View {
    @Environment(TabBarState.self) var tabBarState
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Agent") {
                    NavigationLink("Report Device Info") {
                        ReportDeviceInfoView()
                    }
                }
                
                Section("SSH") {
                    NavigationLink("Manage Identities") {
                        IdentityListView()
                    }
                    NavigationLink("Start SSH Connection") {
                        PrepareConnectionView(host: nil)
                    }
                }
            }
            .contentMargins(.bottom, 60)
            .navigationTitle("Tools")
            .onAppear {
                withAnimation {
                    tabBarState.isToolsViewVisible = true
                }
            }
            .onDisappear {
                withAnimation {
                    tabBarState.isToolsViewVisible = false
                }
            }
        }
    }
}
