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
#if os(iOS) || os(macOS)
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
#endif
    var server: ServerData
    @State private var dateRange: PingChartDateRange = .threeHours
    @State private var pingDatas: [MonitorData] = []
    @State private var loadingState: LoadingState = .idle
    
    var body: some View {
        ScrollView {
            if !pingDatas.isEmpty {
                VStack(spacing: 0) {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(PingChartDateRange.allCases, id: \.rawValue) { dateRange in
                            Text(dateRange.localizedDateRangeTitle)
                                .tag(dateRange)
                        }
                    }
                    .padding()
                    
                    VStack(spacing: 10) {
                        ForEach(pingDatas) { pingData in
                            cardView {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(pingData.monitorName)
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .padding(.top, 10)
                                    
                                    PingChart(pingData: pingData, dateRange: dateRange)
                                        .padding()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            else {
                Text("No data")
            }
        }
        .loadingState(loadingState: loadingState) {
            fetchData()
        }
        .onAppear {
            fetchData()
        }
    }
    
    @ViewBuilder
    private func cardView<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        VStack(spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
            #if os(iOS) || os(macOS)
                .fill(theme.themeSecondaryColor(scheme: scheme))
            #endif
            #if os(visionOS)
                .fill(.thinMaterial)
            #endif
                .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
        )
    }
    
    private func fetchData() {
        if pingDatas.isEmpty {
            loadingState = .loading
            Task {
                do {
                    let response = try await RequestHandler.getMonitor(serverID: server.serverID)
                    withAnimation {
                        if let services = response.data {
                            pingDatas = services.map({
                                MonitorData(
                                    monitorID: $0.monitor_id,
                                    serverID: $0.server_id,
                                    monitorName: $0.monitor_name,
                                    serverName: $0.server_name,
                                    dates: $0.created_at,
                                    delays: $0.avg_delay
                                )
                            })
                        }
                        loadingState = .loaded
                    }
                }
                catch let error as NezhaDashboardError {
                    switch error {
                    case .invalidResponse(let message):
                        if message == "success" {
                            loadingState = .error(String(localized: "No data"))
                        }
                        else {
                            loadingState = .error(String(localized: "Server returned an invalid response."))
#if DEBUG
                            _ = NMCore.debugLog("Nezha Dashboard Handler Error - Invalid response: \(message)")
#endif
                        }
                    default:
                        loadingState = .error(error.localizedDescription)
                    }
                }
                catch {
                    loadingState = .error(error.localizedDescription)
                }
            }
        }
    }
}
