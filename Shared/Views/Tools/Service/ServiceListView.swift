//
//  ServiceListView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import SwiftUI

struct ServiceListView: View {
    @Environment(ServiceViewModel.self) private var serviceViewModel
    
    @State private var isShowAddServiceSheet: Bool = false
    
    @State private var isShowRenameServiceAlert: Bool = false
    @State private var serviceToRename: ServiceData?
    @State private var newNameOfService: String = ""
    
    var body: some View {
        List {
            if !serviceViewModel.services.isEmpty {
                ForEach(serviceViewModel.services) { service in
                    NavigationLink {
                        ServiceDetailView(service: service)
                    } label: {
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
        .canInLoadingStateModifier(loadingState: serviceViewModel.loadingState) {
            serviceViewModel.loadData()
        }
        .navigationTitle("Monitors")
        .toolbar {
            ToolbarItem {
                Button {
                    serviceViewModel.loadData()
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
            if serviceViewModel.loadingState == .idle {
                serviceViewModel.loadData()
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
                await serviceViewModel.refresh()
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
                await serviceViewModel.refresh()
            } catch {
#if DEBUG
                let _ = NMCore.debugLog(error)
#endif
            }
        }
    }
}
