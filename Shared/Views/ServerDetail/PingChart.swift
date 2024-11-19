//
//  PingChart.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/25/24.
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
    let pingData: GetServerPingDataResponse.PingData
    let dateRange: PingChartDateRange
    var pingDataPlots: [PingDataPlot] {
        let plots = zip(pingData.createdAt, pingData.avgDelay)
            .map { PingDataPlot(date: $0, delay: $1) }
        let filteredPlots = plots.filter {
            isTimeDifferenceLessThanHours(from: $0.date, to: Date(), hours: dateRange.rawValue)
        }
        return filteredPlots
    }
    @State private var rawSelectedDate: Date?
    var selectedPingDataPlot: PingDataPlot? {
        guard let rawSelectedDate = rawSelectedDate else { return nil }
        let calendar = Calendar.current
        return pingDataPlots.first { plot in
            calendar.isDate(plot.date, equalTo: rawSelectedDate, toGranularity: .minute)
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(pingDataPlots, id: \.id) { data in
                    LineMark(
                        x: .value("Time", data.date),
                        y: .value("Ping", data.delay)
                    )
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
        .padding(.top, 20)
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
