//
//  EditAlertRuleView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI
import SwiftyJSON

private let allMetricTypes: [String] = [
    "cpu", "gpu", "memory", "swap", "disk",
    "net_in_speed", "net_out_speed", "net_all_speed",
    "transfer_in", "transfer_out", "transfer_all",
    "transfer_in_cycle", "transfer_out_cycle", "transfer_all_cycle",
    "offline",
    "load1", "load5", "load15",
    "process_count", "tcp_conn_count", "udp_conn_count",
    "temperature_max"
]

private let cycleUnits: [String] = ["hour", "day", "week", "month", "year"]

private func isCycleType(_ type: String) -> Bool {
    type == "transfer_in_cycle" || type == "transfer_out_cycle" || type == "transfer_all_cycle"
}

struct EditAlertRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let alertRule: AlertRuleData?

    @State private var isProcessing: Bool = false
    @State private var name: String = ""
    @State private var isEnabled: Bool = true
    @State private var triggerMode: Int64 = 0
    @State private var notificationGroupID: Int64 = 0
    @State private var conditions: [Condition] = []
    @State private var failTriggerTaskIDs: Set<Int64> = []
    @State private var recoverTriggerTaskIDs: Set<Int64> = []

    struct Condition: Identifiable {
        let id = UUID()
        var type: String = "cpu"
        var min: String = ""
        var max: String = ""
        var duration: String = ""
        var cover: Int64 = 0
        var ignore: [String: Bool] = [:]
        var cycleStart: String = ""
        var cycleInterval: String = ""
        var cycleUnit: String = "hour"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enabled", isOn: $isEnabled)
                }
                
                Section {
                    TextField("Name", text: $name)
                    Picker("Trigger Mode", selection: $triggerMode) {
                        ForEach(TriggerMode.allCases) { mode in
                            Text(mode.title)
                                .tag(mode.rawValue)
                        }
                    }
                }

                Section {
                    Picker("Notification Group", selection: $notificationGroupID) {
                        Text("None")
                            .tag(Int64(0))
                        ForEach(state.notificationGroups) { group in
                            Text(group.name)
                                .tag(group.notificationGroupID)
                        }
                    }
                }

                Section {
                    ForEach($conditions) { $condition in
                        DisclosureGroup {
                            Picker("Type", selection: $condition.type) {
                                ForEach(allMetricTypes, id: \.self) { type in
                                    Text(metricTypeTitle(type))
                                        .tag(type)
                                }
                            }
                            TextField("Min", text: $condition.min)
                                .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                                .keyboardType(.decimalPad)
#endif
                            TextField("Max", text: $condition.max)
                                .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                                .keyboardType(.decimalPad)
#endif
                            TextField("Duration (Seconds)", text: $condition.duration)
                                .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                                .keyboardType(.numberPad)
#endif
                            Picker("Coverage", selection: $condition.cover) {
                                Text("All Servers")
                                    .tag(Int64(0))
                                Text("Ignore Specific")
                                    .tag(Int64(1))
                            }
                            if isCycleType(condition.type) {
                                TextField("Cycle Start", text: $condition.cycleStart)
                                    .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                                    .autocapitalization(.none)
#endif
                                TextField("Cycle Interval", text: $condition.cycleInterval)
                                    .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                                    .keyboardType(.numberPad)
#endif
                                Picker("Cycle Unit", selection: $condition.cycleUnit) {
                                    ForEach(cycleUnits, id: \.self) { unit in
                                        Text(unit.capitalized)
                                            .tag(unit)
                                    }
                                }
                            }
                        } label: {
                            Text(metricTypeTitle(condition.type))
                        }
                    }
                    .onDelete { indexSet in
                        conditions.remove(atOffsets: indexSet)
                    }

                    Button {
                        conditions.append(Condition())
                    } label: {
                        Label("Add Condition", systemImage: "plus")
                    }
                } header: {
                    Text("Conditions")
                }

                Section {
                    NavigationLink {
                        TaskPickerView(selectedTaskIDs: $failTriggerTaskIDs)
                            .navigationTitle("Tasks on Alert")
                    } label: {
                        LabeledContent("Tasks on Alert") {
                            Text("\(failTriggerTaskIDs.count) task(s)")
                        }
                    }
                    NavigationLink {
                        TaskPickerView(selectedTaskIDs: $recoverTriggerTaskIDs)
                            .navigationTitle("Tasks on Recovery")
                    } label: {
                        LabeledContent("Tasks on Recovery") {
                            Text("\(recoverTriggerTaskIDs.count) task(s)")
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(alertRule != nil ? "Edit Alert Rule" : "Add Alert Rule")
#if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, macOS 26, visionOS 26, *) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) {
                            dismiss()
                        }
                    }
                    else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if !isProcessing {
                        if #available(iOS 26, macOS 26, visionOS 26, *) {
                            Button("Done", systemImage: "checkmark", role: .confirm) {
                                execute()
                            }
                        }
                        else {
                            Button("Done") {
                                execute()
                            }
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                if state.cronLoadingState == .idle {
                    state.loadCrons()
                }
                if state.notificationGroupLoadingState == .idle {
                    state.loadNotificationGroups()
                }
                if let alertRule {
                    name = alertRule.name
                    isEnabled = alertRule.isEnabled
                    triggerMode = alertRule.triggerOption
                    notificationGroupID = alertRule.notificationGroupID
                    failTriggerTaskIDs = Set(alertRule.failureTaskIDs)
                    recoverTriggerTaskIDs = Set(alertRule.recoverTaskIDs)
                    conditions = alertRule.triggerRule.arrayValue.map { json in
                        Condition(
                            type: json["type"].stringValue,
                            min: json["min"].double.map { formatNumber($0) } ?? "",
                            max: json["max"].double.map { formatNumber($0) } ?? "",
                            duration: json["duration"].int64.map { String($0) } ?? "",
                            cover: json["cover"].int64Value,
                            ignore: (json["ignore"].dictionaryObject as? [String: Bool]) ?? [:],
                            cycleStart: json["cycle_start"].stringValue,
                            cycleInterval: json["cycle_interval"].int64.map { String($0) } ?? "",
                            cycleUnit: json["cycle_unit"].stringValue.isEmpty ? "hour" : json["cycle_unit"].stringValue
                        )
                    }
                }
            }
        }
    }

    private func execute() {
        isProcessing = true
        let rules = conditions.map { conditionToDictionary($0) }
        let failTasks = Array(failTriggerTaskIDs)
        let recoverTasks = Array(recoverTriggerTaskIDs)
        if let alertRule {
            Task {
                do {
                    let _ = try await RequestHandler.updateAlertRule(alertRuleID: alertRule.alertRuleID, name: name, isEnabled: isEnabled, triggerMode: triggerMode, notificationGroupID: notificationGroupID, rules: rules, failTriggerTasks: failTasks, recoverTriggerTasks: recoverTasks)
                    await state.refreshAlertRules()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
        else {
            Task {
                do {
                    let _ = try await RequestHandler.addAlertRule(name: name, isEnabled: isEnabled, triggerMode: triggerMode, notificationGroupID: notificationGroupID, rules: rules, failTriggerTasks: failTasks, recoverTriggerTasks: recoverTasks)
                    await state.refreshAlertRules()
                    isProcessing = false
                    dismiss()
                } catch {
#if DEBUG
                    let _ = NMCore.debugLog(error)
#endif
                    isProcessing = false
                }
            }
        }
    }

    private func conditionToDictionary(_ condition: Condition) -> [String: Any] {
        var dict: [String: Any] = [
            "type": condition.type,
            "cover": condition.cover,
        ]
        if let min = Double(condition.min) { dict["min"] = min }
        if let max = Double(condition.max) { dict["max"] = max }
        if let duration = Int64(condition.duration) { dict["duration"] = duration }
        if !condition.ignore.isEmpty { dict["ignore"] = condition.ignore }
        if isCycleType(condition.type) {
            if !condition.cycleStart.isEmpty { dict["cycle_start"] = condition.cycleStart }
            if let interval = Int64(condition.cycleInterval) { dict["cycle_interval"] = interval }
            dict["cycle_unit"] = condition.cycleUnit
        }
        return dict
    }

    private func formatNumber(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}
