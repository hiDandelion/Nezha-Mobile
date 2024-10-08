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
                if let errorDescriptionLoadingPingData {
                    Text(errorDescriptionLoadingPingData)
                }
                else {
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
                else {
                    Text("No data")
                }
            }
        }
        .onAppear {
            if pingDatas == nil {
                isLoadingPingDatas = true
                Task {
                    do {
                        let response = try await RequestHandler.getServerPingData(serverID: String(server.id))
                        withAnimation {
                            errorDescriptionLoadingPingData = nil
                            pingDatas = response.result
                            isLoadingPingDatas = false
                        }
                    }
                    catch let error as NezhaDashboardError {
                        switch error {
                        case .invalidResponse(let message):
                            if message == "success" {
                                errorDescriptionLoadingPingData = String(localized: "No data")
                            }
                            else {
                                errorDescriptionLoadingPingData = String(localized: "Server returned an invalid response.")
#if DEBUG
                                _ = debugLog("Nezha Dashboard Handler Error - Invalid response: \(message)")
#endif
                            }
                        default:
                            errorDescriptionLoadingPingData = error.localizedDescription
                        }
                    }
                    catch {
                        errorDescriptionLoadingPingData = error.localizedDescription
                    }
                }
            }
        }
    }
}
