//
//  NATListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct NATListView: View {
    @Environment(NMState.self) private var state

    @State private var isShowAddNATSheet: Bool = false

    @State private var isShowRenameNATAlert: Bool = false
    @State private var natToRename: NATData?
    @State private var newNameOfNAT: String = ""

    var body: some View {
        List {
            if !state.nats.isEmpty {
                ForEach(state.nats) { nat in
                    NavigationLink(value: nat) {
                        natLabel(nat: nat)
                    }
                    .renamableAndDeletable {
                        showRenameNATAlert(nat: nat)
                    } deleteAction: {
                        deleteNAT(nat: nat)
                    }
                }
            }
            else {
                Text("No NAT")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.natLoadingState) {
            state.loadNATs()
        }
        .navigationTitle("NAT")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddNATSheet = true
                } label: {
                    Label("Add NAT", systemImage: "plus")
                }
            }
        }
        .onAppear {
            if state.natLoadingState == .idle {
                state.loadNATs()
            }
        }
        .sheet(isPresented: $isShowAddNATSheet, content: {
            EditNATView(nat: nil)
        })
        .alert("Rename NAT", isPresented: $isShowRenameNATAlert) {
            TextField("Name", text: $newNameOfNAT)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameNAT(nat: natToRename!, name: newNameOfNAT)
            }
        } message: {
            Text("Enter a new name for the NAT.")
        }
    }

    private func natLabel(nat: NATData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(nat.name))
            HStack {
                Text(nat.domain)
                Image(systemName: "arrow.right")
                Text(nat.host)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }

    private func deleteNAT(nat: NATData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteNAT(nats: [nat])
                await state.refreshNATs()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }

    private func showRenameNATAlert(nat: NATData) {
        natToRename = nat
        newNameOfNAT = nat.name
        isShowRenameNATAlert = true
    }

    private func renameNAT(nat: NATData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateNAT(nat: nat, name: name)
                await state.refreshNATs()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
