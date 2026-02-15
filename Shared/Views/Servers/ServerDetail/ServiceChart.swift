//
//  ServiceChart.swift
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

struct ServiceChart: View {
    @Environment(\.colorScheme) private var scheme
    let pingData: MonitorData
    let period: MonitorPeriod
    var pingDataPlots: [PingDataPlot] {
        zip(pingData.dates, pingData.delays)
            .map { PingDataPlot(date: $0, delay: $1) }
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
            if pingDataPlots.isEmpty {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
            Chart {
                ForEach(pingDataPlots, id: \.id) { data in
                    LineMark(
                        x: .value("Time", data.date),
                        y: .value("Value", data.delay)
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
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: period.xAxisDateFormat)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXSelection(value: $rawSelectedDate)
            .frame(minHeight: 200)
            }
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
