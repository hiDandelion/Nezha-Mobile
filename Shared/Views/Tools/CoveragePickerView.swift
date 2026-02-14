//
//  CoveragePickerView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct CoveragePickerView: View {
    @Environment(NMState.self) private var state
    @Binding var coverageOption: CoverageType
    @Binding var selectedServerIDs: Set<Int64>

    var body: some View {
        Form {
            Section {
                Picker("Coverage", selection: $coverageOption) {
                    ForEach(CoverageType.allCases) { type in
                        Text(type.title)
                            .tag(type)
                    }
                }
            }

            if coverageOption != .alarmed {
                Section("Servers") {
                    ForEach(state.servers) { server in
                        Button {
                            if selectedServerIDs.contains(server.serverID) {
                                selectedServerIDs.remove(server.serverID)
                            } else {
                                selectedServerIDs.insert(server.serverID)
                            }
                        } label: {
                            HStack {
                                Text(server.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedServerIDs.contains(server.serverID) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Coverage")
#if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}
