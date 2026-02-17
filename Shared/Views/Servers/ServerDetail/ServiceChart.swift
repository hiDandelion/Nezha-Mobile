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
    let pingData: MonitorData
    let period: MonitorPeriod
    @State private var rawSelectedDate: Date?

    private var pingDataPlots: [PingDataPlot] {
        zip(pingData.dates, pingData.delays)
            .map { PingDataPlot(date: $0, delay: $1) }
    }

    private var selectedPlot: PingDataPlot? {
        guard let rawSelectedDate else { return nil }
        return pingDataPlots.min { a, b in
            abs(a.date.timeIntervalSince(rawSelectedDate)) < abs(b.date.timeIntervalSince(rawSelectedDate))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label(pingData.monitorName, systemImage: "chart.xyaxis.line")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if pingDataPlots.isEmpty {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            } else {
                chartContent
                    .chartXSelection(value: $rawSelectedDate)
                    .frame(minHeight: 160)
            }
        }
        .padding(10)
    }

    @ViewBuilder
    private var chartContent: some View {
        Chart {
            ForEach(pingDataPlots) { plot in
                LineMark(
                    x: .value("Time", plot.date),
                    y: .value("Value", plot.delay)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Time", plot.date),
                    y: .value("Value", plot.delay)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            if let rawSelectedDate {
                RuleMark(x: .value("Selected", rawSelectedDate))
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
    }

    private var valueSelectionPopover: some View {
        VStack {
            if let selectedPlot {
                Text("\(selectedPlot.delay, specifier: "%.0f")")
            }
        }
        .font(.system(size: 12, design: .rounded))
        .foregroundStyle(Color.gray)
    }
}
