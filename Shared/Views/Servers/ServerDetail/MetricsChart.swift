//
//  MetricsChart.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/15/26.
//

import SwiftUI
import Charts

struct MetricsChart: View {
    let timeSeries: ServerMetricsTimeSeries
    let period: MonitorPeriod
    @State private var rawSelectedDate: Date?

    private var selectedPlot: MetricsDataPlot? {
        guard let rawSelectedDate else { return nil }
        let calendar = Calendar.current
        return timeSeries.plots.first { plot in
            calendar.isDate(plot.date, equalTo: rawSelectedDate, toGranularity: .minute)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label(timeSeries.localizedTitle, systemImage: timeSeries.systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            if timeSeries.plots.isEmpty {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            } else {
                chartContent
                    .chartXSelection(value: $rawSelectedDate)
                    .frame(minHeight: 160)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        let chart = Chart {
            ForEach(timeSeries.plots) { plot in
                LineMark(
                    x: .value("Time", plot.date),
                    y: .value("Value", plot.value)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Time", plot.date),
                    y: .value("Value", plot.value)
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

        if timeSeries.isPercentage {
            chart.chartYScale(domain: 0...100)
        } else {
            chart
        }
    }

    var valueSelectionPopover: some View {
        VStack {
            if let selectedPlot {
                Text("\(selectedPlot.value, specifier: "%.0f")")
            }
        }
        .font(.system(size: 12, design: .rounded))
        .foregroundStyle(Color.gray)
    }
}
