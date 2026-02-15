//
//  ServerDetailMonitorView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

enum MonitorPeriod: String, CaseIterable {
    case oneDay = "1d"
    case sevenDays = "7d"
    case thirtyDays = "30d"

    var localizedTitle: String {
        switch self {
        case .oneDay: String(localized: "MonitorPeriod.oneDay")
        case .sevenDays: String(localized: "MonitorPeriod.sevenDays")
        case .thirtyDays: String(localized: "MonitorPeriod.thirtyDays")
        }
    }

    var xAxisDateFormat: Date.FormatStyle {
        switch self {
        case .oneDay: .dateTime.hour()
        case .sevenDays: .dateTime.month(.abbreviated).day()
        case .thirtyDays: .dateTime.month(.abbreviated).day()
        }
    }
}

struct ServerDetailMonitorView: View {
#if os(iOS) || os(macOS)
    @Environment(\.colorScheme) private var scheme
    @Environment(NMTheme.self) var theme
#endif
    var server: ServerData
    @State private var period: MonitorPeriod = .oneDay

    @State private var metricsData: [ServerMetricsTimeSeries] = []
    @State private var metricsLoadingState: LoadingState = .idle

    @State private var pingDatas: [MonitorData] = []
    @State private var serviceLoadingState: LoadingState = .idle

    private static let metricKeys = ["cpu", "memory", "swap", "disk", "net_in_speed", "net_out_speed"]


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                metricsSection
                serviceSection
            }
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Menu("More", systemImage: "ellipsis") {
                    Picker("Period", selection: $period) {
                        ForEach(MonitorPeriod.allCases, id: \.rawValue) { p in
                            Text(p.localizedTitle)
                                .tag(p)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchAllData()
        }
        .onChange(of: period) {
            metricsData = []
            metricsLoadingState = .idle
            pingDatas = []
            serviceLoadingState = .idle
            fetchAllData()
        }
    }

    // MARK: - Metrics Section

    @ViewBuilder
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Metrics")
                .font(.headline)
                .foregroundStyle(.secondary)

            switch metricsLoadingState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            case .loaded:
                if metricsData.isEmpty {
                    Text("No Data")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    VStack(spacing: 10) {
                        ForEach(metricsData) { series in
                            cardView {
                                MetricsChart(timeSeries: series, period: period)
                            }
                        }
                    }
                }
            case .error(let message):
                VStack(spacing: 10) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        fetchMetrics()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
    }

    // MARK: - Service Section

    @ViewBuilder
    private var serviceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Services")
                .font(.headline)
                .foregroundStyle(.secondary)

            switch serviceLoadingState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            case .loaded:
                if pingDatas.isEmpty {
                    Text("No Data")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    VStack(spacing: 10) {
                        ForEach(pingDatas) { pingData in
                            cardView {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(pingData.monitorName)
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .padding(.top, 10)

                                    ServiceChart(pingData: pingData, period: period)
                                        .padding()
                                }
                            }
                        }
                    }
                }
            case .error(let message):
                VStack(spacing: 10) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        fetchServiceMonitors()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
    }

    // MARK: - Card View

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

    // MARK: - Data Fetching

    private func fetchAllData() {
        fetchMetrics()
        fetchServiceMonitors()
    }

    private func fetchMetrics() {
        metricsLoadingState = .loading
        Task {
            do {
                let results = try await withThrowingTaskGroup(of: ServerMetricsTimeSeries?.self, returning: [ServerMetricsTimeSeries].self) { group in
                    for metric in Self.metricKeys {
                        group.addTask {
                            let response = try await RequestHandler.getServerMetrics(serverID: server.serverID, metric: metric, period: period.rawValue)
                            guard let data = response.data else { return nil }
                            let plots = data.data_points.map { point in
                                MetricsDataPlot(date: Date(timeIntervalSince1970: TimeInterval(point.ts)), value: point.value)
                            }
                            return ServerMetricsTimeSeries(metric: data.metric, plots: plots)
                        }
                    }
                    var collected: [ServerMetricsTimeSeries] = []
                    for try await result in group {
                        if let result {
                            collected.append(result)
                        }
                    }
                    return collected
                }
                let order = Self.metricKeys
                let sorted = results.sorted { a, b in
                    (order.firstIndex(of: a.metric) ?? Int.max) < (order.firstIndex(of: b.metric) ?? Int.max)
                }
                withAnimation {
                    metricsData = sorted
                    metricsLoadingState = .loaded
                }
            } catch {
                withAnimation {
                    metricsLoadingState = .error(error.localizedDescription)
                }
            }
        }
    }

    private func fetchServiceMonitors() {
        serviceLoadingState = .loading
        Task {
            do {
                let response = try await RequestHandler.getMonitor(serverID: server.serverID, period: period.rawValue)
                withAnimation {
                    if let services = response.data {
                        pingDatas = services.map({
                            MonitorData(
                                monitorID: $0.monitor_id,
                                serverID: $0.server_id,
                                monitorName: $0.monitor_name,
                                serverName: $0.server_name,
                                displayIndex: $0.display_index ?? 0,
                                dates: $0.created_at,
                                delays: $0.avg_delay
                            )
                        }).sorted(by: { $0.displayIndex > $1.displayIndex })
                    }
                    serviceLoadingState = .loaded
                }
            }
            catch let error as NezhaDashboardError {
                switch error {
                case .invalidResponse(let message):
                    if message == "success" {
                        serviceLoadingState = .loaded
                    }
                    else {
                        serviceLoadingState = .error(String(localized: "Server returned an invalid response."))
#if DEBUG
                        _ = NMCore.debugLog("Nezha Dashboard Handler Error - Invalid response: \(message)")
#endif
                    }
                default:
                    serviceLoadingState = .error(error.localizedDescription)
                }
            }
            catch {
                serviceLoadingState = .error(error.localizedDescription)
            }
        }
    }
}
