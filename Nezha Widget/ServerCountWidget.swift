//
//  SummaryWidget.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/28/25.
//

import WidgetKit
import SwiftUI

struct SummaryProvider: AppIntentTimelineProvider {
    typealias Entry = SummaryEntry
    typealias Intent = ServerCountConfigurationIntent

    func placeholder(in context: Context) -> SummaryEntry {
        SummaryEntry(
            date: Date(),
            onlineCount: 47,
            offlineCount: 5,
            totalUpload: 107_374_182_400,
            totalDownload: 536_870_912_000,
            uploadSpeed: 1_048_576,
            downloadSpeed: 5_242_880,
            message: "Placeholder",
            color: .blue
        )
    }

    func snapshot(for configuration: ServerCountConfigurationIntent, in context: Context) async -> SummaryEntry {
        let color = configuration.color ?? .blue
        return await getSummaryEntry(color: color)
    }

    func timeline(for configuration: ServerCountConfigurationIntent, in context: Context) async -> Timeline<SummaryEntry> {
        let color = configuration.color ?? .blue
        let entry = await getSummaryEntry(color: color)
        return Timeline(entries: [entry], policy: .atEnd)
    }

    func getSummaryEntry(color: WidgetBackgroundColor) async -> SummaryEntry {
        do {
            let response = try await RequestHandler.getServer()
            if let data = response.data {
                let onlineCount = data.filter({ isServerOnline(timestamp: $0.last_active) }).count
                let offlineCount = data.count - onlineCount
                let totalUpload = data.reduce(Int64(0)) { $0 + ($1.state.net_out_transfer ?? 0) }
                let totalDownload = data.reduce(Int64(0)) { $0 + ($1.state.net_in_transfer ?? 0) }
                let uploadSpeed = data.reduce(Int64(0)) { $0 + ($1.state.net_out_speed ?? 0) }
                let downloadSpeed = data.reduce(Int64(0)) { $0 + ($1.state.net_in_speed ?? 0) }
                return SummaryEntry(date: Date(), onlineCount: onlineCount, offlineCount: offlineCount, totalUpload: totalUpload, totalDownload: totalDownload, uploadSpeed: uploadSpeed, downloadSpeed: downloadSpeed, message: "OK", color: color)
            }
            else {
                return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: "No Server Data", color: color)
            }
        }
        catch NezhaDashboardError.invalidDashboardConfiguration {
            return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: String(localized: "error.invalidDashboardConfiguration"), color: color)
        } catch NezhaDashboardError.dashboardAuthenticationFailed {
            return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: String(localized: "error.dashboardAuthenticationFailed"), color: color)
        } catch NezhaDashboardError.invalidResponse(let message) {
            return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: message, color: color)
        } catch NezhaDashboardError.decodingError {
            return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: String(localized: "error.errorDecodingData"), color: color)
        } catch {
            return SummaryEntry(date: Date(), onlineCount: nil, offlineCount: nil, totalUpload: nil, totalDownload: nil, uploadSpeed: nil, downloadSpeed: nil, message: error.localizedDescription, color: color)
        }
    }
}

struct SummaryWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: SummaryProvider.Entry
    var color: AnyGradient {
        switch(entry.color) {
        case .blue:
            return Color.blue.gradient
        case .green:
            return Color.green.gradient
        case .orange:
            return Color.orange.gradient
        case .black:
            return Color.black.gradient
        }
    }

    var body: some View {
        Group {
            if entry.onlineCount != nil {
                Group {
                    switch(family) {
                    case .systemSmall:
                        summaryViewSystemSmall
                            .foregroundStyle(.white)
                            .tint(.white)
                            .containerBackground(color, for: .widget)
                    case .systemMedium:
                        summaryViewSystemMedium
                            .foregroundStyle(.white)
                            .tint(.white)
                            .containerBackground(color, for: .widget)
                    default:
                        Text("Unsupported family")
                            .containerBackground(color, for: .widget)
                    }
                }
            }
            else {
                VStack {
                    Text(entry.message)
                    Button(intent: RefreshWidgetIntent()) {
                        Text("Retry")
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .foregroundStyle(.white)
                .containerBackground(color, for: .widget)
            }
        }
    }

    var summaryViewSystemSmall: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Summary")
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.footnote)

            Spacer()

            HStack {
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 6))
                    Text("\(entry.onlineCount ?? 0)")
                        .font(.system(size: 24, design: .rounded))
                }
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 6))
                    Text("\(entry.offlineCount ?? 0)")
                        .font(.system(size: 24, design: .rounded))
                }
                Spacer()
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)

            Spacer()

            VStack(spacing: 3) {
                HStack {
                    Image(systemName: "circle.dotted.circle")
                        .frame(width: 10)
                    Text("↑ \(formatBytes(entry.totalUpload ?? 0, decimals: 1))")
                    Spacer()
                    Text("↓ \(formatBytes(entry.totalDownload ?? 0, decimals: 1))")
                }
                HStack {
                    Image(systemName: "network")
                        .frame(width: 10)
                    Text("↑ \(formatBytes(entry.uploadSpeed ?? 0, decimals: 1))/s")
                    Spacer()
                    Text("↓ \(formatBytes(entry.downloadSpeed ?? 0, decimals: 1))/s")
                }
            }
            .font(.system(size: 10))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
    }

    var summaryViewSystemMedium: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Summary")
                Spacer()
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.subheadline)

            HStack(spacing: 20) {
                // Server counts
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 8))
                        Text("\(entry.onlineCount ?? 0)")
                            .font(.system(size: 32, design: .rounded))
                    }
                    VStack(spacing: 2) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 8))
                        Text("\(entry.offlineCount ?? 0)")
                            .font(.system(size: 24, design: .rounded))
                    }
                }
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                // Traffic info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "circle.dotted.circle")
                            .frame(width: 10)
                        VStack(alignment: .leading) {
                            Text("↑ \(formatBytes(entry.totalUpload ?? 0, decimals: 1))")
                            Text("↓ \(formatBytes(entry.totalDownload ?? 0, decimals: 1))")
                        }
                    }
                    HStack {
                        Image(systemName: "network")
                            .frame(width: 10)
                        VStack(alignment: .leading) {
                            Text("↑ \(formatBytes(entry.uploadSpeed ?? 0, decimals: 1))/s")
                            Text("↓ \(formatBytes(entry.downloadSpeed ?? 0, decimals: 1))/s")
                        }
                    }
                }
                .font(.system(size: 12))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SummaryEntry: TimelineEntry {
    let date: Date
    let onlineCount: Int?
    let offlineCount: Int?
    let totalUpload: Int64?
    let totalDownload: Int64?
    let uploadSpeed: Int64?
    let downloadSpeed: Int64?
    let message: String
    let color: WidgetBackgroundColor
}

struct SummaryWidget: Widget {
    let kind: String = "ServerCountWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerCountConfigurationIntent.self, provider: SummaryProvider()) { entry in
            SummaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Summary")
        .description("View online/offline server counts and total traffic at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
