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
                    NavigationLink {
                        ReportDeviceInfoView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "Report Device Info", systemName: "text.page", color: .blue)
                    }
                }
                
                Section("SSH") {
                    NavigationLink {
                        IdentityListView()
                    } label: {
                        TextWithColorfulIcon(titleKey: "Manage Identities", systemName: "key", color: .gray)
                    }
                    NavigationLink {
                        PrepareConnectionView(host: nil)
                    } label: {
                        TextWithColorfulIcon(titleKey: "Start SSH Connection", systemName: "apple.terminal", color: .blue)
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
