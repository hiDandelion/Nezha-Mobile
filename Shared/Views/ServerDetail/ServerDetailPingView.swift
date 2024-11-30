//
//  ServerDetailPingChartView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

enum PingChartDateRange: Int, CaseIterable {
    case threeHours = 3
    case sixHours = 6
    case twelveHours = 12
    case oneDay = 24
    
    var localizedDateRangeTitle: String {
        switch self {
        case .threeHours: String(localized: "PingChartDateRange.threeHours")
        case .sixHours: String(localized: "PingChartDateRange.sixHours")
        case .twelveHours: String(localized: "PingChartDateRange.twelveHours")
        case .oneDay: String(localized: "PingChartDateRange.oneDay")
        }
    }
}

struct ServerDetailPingChartView: View {
    @Environment(\.scenePhase) private var scenePhase
    var server: ServerData
    @State private var dateRange: PingChartDateRange = .threeHours
    @State private var pingDatas: [ServiceData]?
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
                    Section {
                        Picker("Date Range", selection: $dateRange) {
                            ForEach(PingChartDateRange.allCases, id: \.rawValue) { dateRange in
                                Text(dateRange.localizedDateRangeTitle)
                                    .tag(dateRange)
                            }
                        }
                    }
                    
                    List {
                        ForEach(pingDatas) { pingData in
                            Section("\(pingData.monitorName)") {
                                PingChart(pingData: pingData, dateRange: dateRange)
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
                        let response = try await RequestHandler.getService(serverID: String(server.serverID))
                        withAnimation {
                            errorDescriptionLoadingPingData = nil
                            if let services = response.data {
                                pingDatas = services.map({
                                    ServiceData(
                                        id: UUID().uuidString,
                                        monitorID: $0.monitor_id,
                                        serverID: $0.server_id,
                                        monitorName: $0.monitor_name,
                                        serverName: $0.server_name,
                                        dates: $0.created_at,
                                        delays: $0.avg_delay
                                    )
                                })
                            }
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
                                _ = NMCore.debugLog("Nezha Dashboard Handler Error - Invalid response: \(message)")
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
