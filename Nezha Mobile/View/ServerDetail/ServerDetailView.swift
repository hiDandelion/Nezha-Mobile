//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import Charts

struct ServerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    var server: Server
    @State private var selectedSection: Int = 0
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            VStack {
                if server.status.uptime != 0 {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        VStack {
                            Picker("Section", selection: $selectedSection) {
                                Text("Basic").tag(0)
                                Text("Status").tag(1)
                                Text("Ping").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            Form {
                                switch(selectedSection) {
                                case 0:
                                    ServerDetailBasicView(server: server)
                                    ServerDetailHostView(server: server)
                                case 1:
                                    ServerDetailStatusView(server: server)
                                case 2:
                                    ServerDetailPingChartView(server: server)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                else {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                    }
                    else {
                        // ContentUnavailableView ×
                        Text("Server Unavailable")
                    }
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
