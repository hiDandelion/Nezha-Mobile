//
//  CronDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct CronDetailView: View {
    @Environment(NMState.self) private var state
    let cronID: Int64
    var cron: CronData? {
        state.crons.first(where: { $0.cronID == cronID })
    }

    @State private var isShowEditCronSheet: Bool = false
    @State private var isRunning: Bool = false

    var body: some View {
        if let cron {
            Form {
                Section {
                    NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(cron.name)"))
                    NMUI.PieceOfInfo(systemImage: "gearshape", name: "Type", content: Text("\(cron.taskType.title)"))
                    if cron.taskType == .scheduled {
                        NMUI.PieceOfInfo(systemImage: "clock", name: "Scheduler", content: Text("\(cron.scheduler)"))
                    }
                }

                Section {
                    NMUI.PieceOfInfo(systemImage: "terminal", name: "Command", content: Text("\(cron.command)"))
                    NMUI.PieceOfInfo(systemImage: "server.rack", name: "Coverage", content: Text("\(CoverageType(rawValue: cron.coverageOption)?.title ?? "")"))
                }

                Section("Last Execution") {
                    NMUI.PieceOfInfo(systemImage: "clock.arrow.circlepath", name: "Last Executed At", content: Text(cron.lastExecutedAt.isEmpty ? "Never" : cron.lastExecutedAt))
                    NMUI.PieceOfInfo(systemImage: cron.lastResult ? "checkmark.circle" : "xmark.circle", name: "Last Result", content: Text(cron.lastResult ? "Success" : "Failure"))
                }

                Section {
                    if !isRunning {
                        Button {
                            runCron()
                        } label: {
                            Label("Run Now", systemImage: "play")
                        }
                    }
                    else {
                        HStack {
                            Label("Running...", systemImage: "play")
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(nameCanBeUntitled(cron.name))
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowEditCronSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowEditCronSheet, content: {
                EditCronView(cron: cron)
            })
        }
    }

    private func runCron() {
        guard let cron else { return }
        isRunning = true
        Task {
            do {
                let _ = try await RequestHandler.runCron(cronID: cron.cronID)
                isRunning = false
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
                isRunning = false
            }
        }
    }
}
