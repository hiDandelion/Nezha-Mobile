//
//  LiveActivity.swift
//  Nezha Widget
//
//  Created by Junhui Lou on 8/12/24.
//

#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var name: String
        var id: Int
        var cpu: Double
        var memUsed: Int64
        var diskUsed: Int64
        var memTotal: Int64
        var diskTotal: Int64
        var netInTransfer: Int64
        var netOutTransfer: Int64
        var load1: Double
        var uptime: Int64
    }
}

@available(iOS 17.2, *)
struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            VStack {
                HStack {
                    Text("Load \(context.state.load1, specifier: "%.2f")")
                    Spacer()
                    Button(intent: RefreshLiveActivityIntent()) {
                        HStack {
                            Text(Date().formatted(date: .omitted, time: .shortened))
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack {
                    Text("\(context.state.name)")
                    HStack {
                        gaugeView(context: context)
                        infoView(context: context)
                        .padding(.leading, 10)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(nil)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Load \(context.state.load1, specifier: "%.2f")")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: RefreshLiveActivityIntent()) {
                        HStack(spacing: 5) {
                            Text(Date().formatted(date: .omitted, time: .shortened))
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        HStack {
                            Text("\(context.state.name)")
                        }
                        HStack {
                            gaugeView(context: context)
                            infoView(context: context)
                            .padding(.leading, 10)
                        }
                    }
                }
            } compactLeading: {
                Text("Load")
            } compactTrailing: {
                Text("\(context.state.load1, specifier: "%.2f")")
            } minimal: {
                Text("\(context.state.load1, specifier: "%.2f")")
            }
        }
    }
    
    func gaugeView(context: ActivityViewContext<LiveActivityAttributes>) -> some View {
        HStack {
            let cpuUsage = context.state.cpu / 100
            let memUsage = (context.state.memTotal == 0 ? 0 : Double(context.state.memUsed) / Double(context.state.memTotal))
            let diskUsage = (context.state.diskTotal == 0 ? 0 : Double(context.state.diskUsed) / Double(context.state.diskTotal))
            
            Gauge(value: cpuUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("CPU")
                    Text("\(cpuUsage * 100, specifier: "%.0f")%")
                }
            }
            
            Gauge(value: memUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("MEM")
                    Text("\(memUsage * 100, specifier: "%.0f")%")
                }
            }
            
            Gauge(value: diskUsage) {
                
            } currentValueLabel: {
                VStack {
                    Text("DISK")
                    Text("\(diskUsage * 100, specifier: "%.0f")%")
                }
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(.cyan)
    }
    
    func infoView(context: ActivityViewContext<LiveActivityAttributes>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "power")
                    .frame(width: 10)
                Text("\(formatTimeInterval(seconds: context.state.uptime))")
            }
            
            HStack {
                Image(systemName: "circle.dotted.circle")
                    .frame(width: 10)
                VStack(alignment: .leading) {
                    Text("↑\(formatBytes(context.state.netOutTransfer))")
                    Text("↓\(formatBytes(context.state.netInTransfer))")
                }
            }
        }
        .font(.footnote)
    }
}

@available(iOS 17.2, *)
extension LiveActivityAttributes {
    fileprivate static var preview: LiveActivityAttributes {
        LiveActivityAttributes()
    }
}

@available(iOS 17.2, *)
extension LiveActivityAttributes.ContentState {
    fileprivate static var demo: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(name: "Demo Server", id: 1, cpu: 50, memUsed: 512000, diskUsed: 512000, memTotal: 1024000, diskTotal: 1024000, netInTransfer: 1024000, netOutTransfer: 1024000, load1: 2.0, uptime: 600)
    }
}

//@available(iOS 17.2, *)
//#Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
//    LiveActivity()
//} contentStates: {
//    LiveActivityAttributes.ContentState.demo
//}
#endif
