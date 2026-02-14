//
//  EditCronView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct EditCronView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NMState.self) private var state
    let cron: CronData?

    @State private var isProcessing: Bool = false
    @State private var name: String = ""
    @State private var taskType: CronTaskType = .scheduled
    @State private var scheduler: String = ""
    @State private var command: String = ""
    @State private var coverageOption: CoverageType = .only
    @State private var selectedServerIDs: Set<Int64> = []
    @State private var notificationGroupID: Int64 = 0
    @State private var pushSuccessful: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }

                Section {
                    Picker("Task Type", selection: $taskType) {
                        ForEach(CronTaskType.allCases) { type in
                            Text(type.title)
                                .tag(type)
                        }
                    }
                    
                }
                
                Section("Scheduler") {
                    if taskType == .scheduled {
                        TextField("Cron Expression", text: $scheduler)
                            .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
#endif
                    }
                }

                Section("Command") {
                    TextEditor(text: $command)
                        .monospaced()
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
#endif
                        .frame(minHeight: 100)
                }

                Section {
                    NavigationLink {
                        CoveragePickerView(coverageOption: $coverageOption, selectedServerIDs: $selectedServerIDs)
                    } label: {
                        LabeledContent("Coverage") {
                            if coverageOption == .alarmed {
                                Text(coverageOption.title)
                            } else {
                                Text("\(selectedServerIDs.count) server(s)")
                            }
                        }
                    }
                }

                Section("Notification") {
                    Picker("Notification Group", selection: $notificationGroupID) {
                        Text("None")
                            .tag(Int64(0))
                        ForEach(state.notificationGroups) { group in
                            Text(group.name)
                                .tag(group.notificationGroupID)
                        }
                    }
                    Toggle("Push on Success", isOn: $pushSuccessful)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(cron != nil ? "Edit Task" : "Add Task")
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
                if let cron {
                    name = cron.name
                    taskType = cron.taskType
                    scheduler = cron.scheduler
                    command = cron.command
                    coverageOption = CoverageType(rawValue: cron.coverageOption) ?? .only
                    selectedServerIDs = Set(cron.serverIDs)
                    notificationGroupID = cron.notificationGroupID
                    pushSuccessful = cron.pushSuccessful
                }
            }
        }
    }

    private func execute() {
        isProcessing = true
        let serverIDs = Array(selectedServerIDs)
        if let cron {
            Task {
                do {
                    let _ = try await RequestHandler.updateCron(cron: cron, name: name, taskType: taskType.rawValue, scheduler: scheduler, command: command, cover: coverageOption.rawValue, servers: serverIDs, notificationGroupID: notificationGroupID, pushSuccessful: pushSuccessful)
                    await state.refreshCrons()
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
                    let _ = try await RequestHandler.addCron(name: name, taskType: taskType.rawValue, scheduler: scheduler, command: command, cover: coverageOption.rawValue, servers: serverIDs, notificationGroupID: notificationGroupID, pushSuccessful: pushSuccessful)
                    await state.refreshCrons()
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
}
