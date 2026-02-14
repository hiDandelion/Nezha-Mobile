//
//  DDNSListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct DDNSListView: View {
    @Environment(NMState.self) private var state

    @State private var isShowAddDDNSSheet: Bool = false

    @State private var isShowRenameDDNSAlert: Bool = false
    @State private var ddnsToRename: DDNSData?
    @State private var newNameOfDDNS: String = ""

    var body: some View {
        List {
            if !state.ddnsProfiles.isEmpty {
                ForEach(state.ddnsProfiles) { ddns in
                    NavigationLink(value: ddns) {
                        ddnsLabel(ddns: ddns)
                    }
                    .renamableAndDeletable {
                        showRenameDDNSAlert(ddns: ddns)
                    } deleteAction: {
                        deleteDDNS(ddns: ddns)
                    }
                }
            }
            else {
                Text("No DDNS")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.ddnsLoadingState) {
            state.loadDDNS()
        }
        .navigationTitle("DDNS")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddDDNSSheet = true
                } label: {
                    Label("Add DDNS", systemImage: "plus")
                }
            }
        }
        .onAppear {
            if state.ddnsLoadingState == .idle {
                state.loadDDNS()
            }
        }
        .sheet(isPresented: $isShowAddDDNSSheet, content: {
            EditDDNSView(ddns: nil)
        })
        .alert("Rename DDNS", isPresented: $isShowRenameDDNSAlert) {
            TextField("Name", text: $newNameOfDDNS)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameDDNS(ddns: ddnsToRename!, name: newNameOfDDNS)
            }
        } message: {
            Text("Enter a new name for the DDNS.")
        }
    }

    private func ddnsLabel(ddns: DDNSData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(ddns.name))
            HStack {
                Text(ddns.provider)
                Text(ddns.domains.joined(separator: ", "))
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }

    private func deleteDDNS(ddns: DDNSData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteDDNS(ddnsProfiles: [ddns])
                await state.refreshDDNS()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func showRenameDDNSAlert(ddns: DDNSData) {
        ddnsToRename = ddns
        newNameOfDDNS = ddns.name
        isShowRenameDDNSAlert = true
    }

    private func renameDDNS(ddns: DDNSData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateDDNS(ddns: ddns, name: name)
                await state.refreshDDNS()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
