//
//  ServiceListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import SwiftUI

struct ServiceListView: View {
    @Environment(NMState.self) private var state
    
    @State private var isShowAddServiceSheet: Bool = false
    
    @State private var isShowRenameServiceAlert: Bool = false
    @State private var serviceToRename: ServiceData?
    @State private var newNameOfService: String = ""
    
    var body: some View {
        List {
            if !state.services.isEmpty {
                ForEach(state.services) { service in
                    NavigationLink(value: service) {
                        serviceLabel(service: service)
                    }
                    .renamableAndDeletable {
                        showRenameServiceAlert(service: service)
                    } deleteAction: {
                        deleteService(service: service)
                    }
                }
            }
            else {
                Text("No Monitor")
                    .foregroundStyle(.secondary)
            }
        }
        .loadingState(loadingState: state.serviceLoadingState) {
            state.loadServices()
        }
        .navigationTitle("Monitors")
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await state.refreshServices()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            ToolbarItem {
                Button {
                    isShowAddServiceSheet = true
                } label: {
                    Label("Add Monitor", systemImage: "plus")
                }
            }
        }
        .onAppear {
            if state.serviceLoadingState == .idle {
                state.loadServices()
            }
        }
        .sheet(isPresented: $isShowAddServiceSheet, content: {
            EditServiceView(service: nil)
        })
        .alert("Rename Monitor", isPresented: $isShowRenameServiceAlert) {
            TextField("Name", text: $newNameOfService)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                renameService(service: serviceToRename!, name: newNameOfService)
            }
        } message: {
            Text("Enter a new name for the monitor.")
        }
    }
    
    private func serviceLabel(service: ServiceData) -> some View {
        VStack(alignment: .leading) {
            Text(nameCanBeUntitled(service.name))
            HStack {
                Text(service.type.title)
                Text(service.target)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
        }
        .lineLimit(1)
    }
    
    private func deleteService(service: ServiceData) {
        Task {
            do {
                let _ = try await RequestHandler.deleteService(services: [service])
                await state.refreshServices()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
    
    private func showRenameServiceAlert(service: ServiceData) {
        serviceToRename = service
        newNameOfService = service.name
        isShowRenameServiceAlert = true
    }
    
    private func renameService(service: ServiceData, name: String) {
        Task {
            do {
                let _ = try await RequestHandler.updateService(service: service, name: name)
                await state.refreshServices()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
