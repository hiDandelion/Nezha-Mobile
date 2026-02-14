//
//  TaskPickerView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct TaskPickerView: View {
    @Environment(NMState.self) private var state
    @Binding var selectedTaskIDs: Set<Int64>

    var body: some View {
        Form {
            if !state.crons.isEmpty {
                Section {
                    ForEach(state.crons) { cron in
                        Button {
                            if selectedTaskIDs.contains(cron.cronID) {
                                selectedTaskIDs.remove(cron.cronID)
                            } else {
                                selectedTaskIDs.insert(cron.cronID)
                            }
                        } label: {
                            HStack {
                                Text(nameCanBeUntitled(cron.name))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedTaskIDs.contains(cron.cronID) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("No Task", systemImage: "clock.badge.questionmark")
            }
        }
        .formStyle(.grouped)
#if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}
