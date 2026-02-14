//
//  AlertRuleDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI
import SwiftyJSON

struct AlertRuleDetailView: View {
    @Environment(NMState.self) private var state
    let alertRuleID: Int64
    var alertRule: AlertRuleData? {
        state.alertRules.first(where: { $0.alertRuleID == alertRuleID })
    }

    @State private var isShowEditAlertRuleSheet: Bool = false
    @State private var isToggling: Bool = false

    var body: some View {
        if let alertRule {
            Form {
                Section {
                    if !isToggling {
                        Toggle("Enabled", isOn: Binding(
                            get: { alertRule.isEnabled },
                            set: { newValue in
                                toggleAlertRule(alertRule: alertRule, isEnabled: newValue)
                            }
                        ))
                    }
                    else {
                        HStack {
                            Text("Enabled")
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                
                Section {
                    NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(alertRule.name)"))
                    NMUI.PieceOfInfo(systemImage: "bell.badge", name: "Trigger Mode", content: Text("\(TriggerMode(rawValue: alertRule.triggerOption)?.title ?? "")"))
                }

                Section {
                    let groupName = state.notificationGroups.first(where: { $0.notificationGroupID == alertRule.notificationGroupID })?.name
                    NMUI.PieceOfInfo(systemImage: "bell.badge.circle", name: "Notification Group", content: Text(groupName ?? (alertRule.notificationGroupID == 0 ? String(localized: "None") : "#\(alertRule.notificationGroupID)")))
                }

                Section("Conditions") {
                    if let rules = alertRule.triggerRule.array, !rules.isEmpty {
                        ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(metricTypeTitle(rule["type"].stringValue))
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    if let min = rule["min"].double {
                                        Text("Min: \(formatNumber(min))")
                                    }
                                    if let max = rule["max"].double {
                                        Text("Max: \(formatNumber(max))")
                                    }
                                    if let duration = rule["duration"].int64 {
                                        Text("Duration: \(duration)s")
                                    }
                                }
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    else {
                        Text("No Conditions")
                            .foregroundStyle(.secondary)
                    }
                }

                if !alertRule.failureTaskIDs.isEmpty {
                    Section("Tasks on Alert") {
                        ForEach(alertRule.failureTaskIDs, id: \.self) { taskID in
                            let taskName = state.crons.first(where: { $0.cronID == taskID })?.name
                            Text(taskName ?? "#\(taskID)")
                        }
                    }
                }

                if !alertRule.recoverTaskIDs.isEmpty {
                    Section("Tasks on Recovery") {
                        ForEach(alertRule.recoverTaskIDs, id: \.self) { taskID in
                            let taskName = state.crons.first(where: { $0.cronID == taskID })?.name
                            Text(taskName ?? "#\(taskID)")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(nameCanBeUntitled(alertRule.name))
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowEditAlertRuleSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowEditAlertRuleSheet) {
                EditAlertRuleView(alertRule: alertRule)
            }
            .onAppear {
                if state.cronLoadingState == .idle {
                    state.loadCrons()
                }
                if state.notificationGroupLoadingState == .idle {
                    state.loadNotificationGroups()
                }
            }
        }
    }

    private func toggleAlertRule(alertRule: AlertRuleData, isEnabled: Bool) {
        isToggling = true
        Task {
            do {
                let _ = try await RequestHandler.updateAlertRule(alertRule: alertRule, isEnabled: isEnabled)
                await state.refreshAlertRules()
                isToggling = false
            } catch {
                isToggling = false
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func formatNumber(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}

func metricTypeTitle(_ type: String) -> String {
    switch type {
    case "cpu": "CPU"
    case "gpu": "GPU"
    case "memory": String(localized: "Memory")
    case "swap": "Swap"
    case "disk": String(localized: "Disk")
    case "net_in_speed": String(localized: "Network In Speed")
    case "net_out_speed": String(localized: "Network Out Speed")
    case "net_all_speed": String(localized: "Network All Speed")
    case "transfer_in": String(localized: "Transfer In")
    case "transfer_out": String(localized: "Transfer Out")
    case "transfer_all": String(localized: "Transfer All")
    case "transfer_in_cycle": String(localized: "Transfer In (Cycle)")
    case "transfer_out_cycle": String(localized: "Transfer Out (Cycle)")
    case "transfer_all_cycle": String(localized: "Transfer All (Cycle)")
    case "offline": String(localized: "Offline")
    case "load1": "Load 1"
    case "load5": "Load 5"
    case "load15": "Load 15"
    case "process_count": String(localized: "Process Count")
    case "tcp_conn_count": String(localized: "TCP Connections")
    case "udp_conn_count": String(localized: "UDP Connections")
    case "temperature_max": String(localized: "Max Temperature")
    default: type
    }
}
