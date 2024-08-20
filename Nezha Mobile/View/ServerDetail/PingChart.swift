//
//  PingChart.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/10/24.
//

import SwiftUI
import Charts

struct PingDataPlot: Identifiable {
    let id = UUID()
    let date: Date
    let delay: Double
}

struct PingChart: View {
    @Environment(\.colorScheme) private var scheme
    let pingData: PingData
    @State private var pingDataPlots: [PingDataPlot]
    @ObservedObject var themeStore: ThemeStore
    @State private var rawSelectedDate: Date?
    var selectedPingDataPlot: PingDataPlot? {
        guard let rawSelectedDate = rawSelectedDate else { return nil }
        let calendar = Calendar.current
        return pingDataPlots.first { plot in
            calendar.isDate(plot.date, equalTo: rawSelectedDate, toGranularity: .minute)
        }
    }
    
    init(pingData: PingData, themeStore: ThemeStore) {
        self.pingData = pingData
        let plots = zip(pingData.createdAt, pingData.avgDelay).map { PingDataPlot(date: $0, delay: $1) }
        self._pingDataPlots = State(initialValue: plots)
        self.themeStore = themeStore
    }
    
    var body: some View {
        VStack {
            Text("\(pingData.monitorName)")
                .padding(.bottom, 15)
            if #available(iOS 17.0, *) {
                Chart {
                    ForEach(pingDataPlots, id: \.id) { data in
                        LineMark(
                            x: .value("Time", data.date),
                            y: .value("Ping", data.delay)
                        )
                        .foregroundStyle(themeStore.themeTintColor(scheme: scheme))
                    }
                    
                    if let rawSelectedDate {
                        RuleMark(
                            x: .value("Selected", rawSelectedDate)
                        )
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .offset(yStart: -10)
                        .zIndex(-1)
                        .annotation(
                            position: .top, spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled
                            )
                        ) {
                            valueSelectionPopover
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks() { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXSelection(value: $rawSelectedDate)
                .frame(minHeight: 200)
            }
            else {
                Chart {
                    ForEach(pingDataPlots, id: \.id) { data in
                        LineMark(
                            x: .value("Time", data.date),
                            y: .value("Ping", data.delay)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks() { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(minHeight: 200)
            }
        }
    }
    
    var valueSelectionPopover: some View {
        VStack {
            if let selectedPingDataPlot {
                Text("\(selectedPingDataPlot.delay, specifier: "%.0f")")
            }
        }
        .font(.system(size: 12, design: .rounded))
        .foregroundStyle(Color.gray)
    }
}
