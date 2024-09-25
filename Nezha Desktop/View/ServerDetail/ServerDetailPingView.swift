//
//  ServerDetailPingChartView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailPingChartView: View {
    @Environment(\.scenePhase) private var scenePhase
    var server: Server
    @State private var pingDatas: [PingData]?
    @State private var errorDescriptionLoadingPingData: String?
    @State private var isLoadingPingDatas: Bool = false
    
    var body: some View {
        Group {
            if isLoadingPingDatas {
                Section("Ping") {
                    ProgressView()
                }
            }
            else {
                if let pingDatas {
                    List {
                        ForEach(pingDatas) { pingData in
                            Section("\(pingData.monitorName)") {
                                PingChart(pingData: pingData)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                else if let errorDescriptionLoadingPingData {
                    Text(errorDescriptionLoadingPingData)
                }
                else {
                    Text("No data")
                }
            }
        }
        .onAppear {
            if pingDatas == nil {
                Task {
                    do {
                        isLoadingPingDatas = true
                        let response = try await RequestHandler.getServerPingData(serverID: String(server.id))
                        withAnimation {
                            errorDescriptionLoadingPingData = nil
                            pingDatas = response.result
                            isLoadingPingDatas = false
                        }
                    }
                    catch {
                        errorDescriptionLoadingPingData = error.localizedDescription
                        isLoadingPingDatas = false
                    }
                }
            }
        }
    }
}
