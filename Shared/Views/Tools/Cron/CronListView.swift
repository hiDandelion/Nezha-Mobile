//
//  CronListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct CronListView: View {
    @Environment(NMState.self) private var state

    @State private var isShowAddCronSheet: Bool = false

    @State private var isShowRenameCronAlert: Bool = false
    @State private var cronToRename: CronData?
    @State private var newNameOfCron: String = ""

    var body: some View {
        List {
            if !state.crons.isEmpty {
                ForEach(state.crons) { cron in
                    NavigationLink(value: cron) {
                        cronLabel(cron: cron)
                    }
                    .renamableAndDeletable {
                        showRenameCronAlert(cron: cron)
                    } deleteAction: {
                        deleteCron(cron: cron)
                    }
                    .contextMenu {
                        Button {
                            runCron(cron: cron)
                        } label: {
                            Label("Run Now", systemImage: "play")
                        }
                    }
                }
            }
            else {
                Text("No Task")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.cronLoadingState) {
            state.loadCrons()
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddCronSheet = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .onAppear {
            if state.cronLoadingState == .idle {
                state.loadCrons()
            }
        }
        .sheet(isPresented: $isShowAddCronSheet, content: {
            EditCronView(cron: nil)
        })
        .alert("Rename Task", isPresented: $isShowRenameCronAlert) {
            TextField("Name", text: $newNameOfCron)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameCron(cron: cronToRename!, name: newNameOfCron)
            }
        } message: {
            Text("Enter a new name for the task.")
        }
    }

    private func cronLabel(cron: CronData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(cron.name))
            HStack {
                Text(cron.taskType.title)
                if !cron.scheduler.isEmpty {
                    Text(cron.scheduler)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }

    private func deleteCron(cron: CronData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteCron(crons: [cron])
                await state.refreshCrons()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func runCron(cron: CronData) {
        Task {
            do {
                let _ = try await RequestHandler.runCron(cronID: cron.cronID)
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func showRenameCronAlert(cron: CronData) {
        cronToRename = cron
        newNameOfCron = cron.name
        isShowRenameCronAlert = true
    }

    private func renameCron(cron: CronData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateCron(cron: cron, name: name)
                await state.refreshCrons()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
