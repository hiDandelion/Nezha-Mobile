//
//  SettingView.swift
//  Watch App Watch App
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @State private var dashboardLink: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardLink") ?? ""
    @State private var dashboardAPIToken: String = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")!.string(forKey: "NMDashboardAPIToken") ?? ""
    @State private var isNeedReconnection: Bool = false {
        didSet {
            DispatchQueue.main.async {
                dashboardViewModel.stopMonitoring()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dashboard") {
                    TextField("Dashboard Link", text: $dashboardLink)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: dashboardLink) { _ in
                            DispatchQueue.main.async {
                                isNeedReconnection = true
                            }
                        }
                    TextField("API Token", text: $dashboardAPIToken)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: dashboardAPIToken) { _ in
                            DispatchQueue.main.async {
                                isNeedReconnection = true
                            }
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if !dashboardViewModel.isMonitoringEnabled {
                            dashboardViewModel.startMonitoring()
                        }
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile") else {
                            dismiss()
                            return
                        }
                        if !dashboardViewModel.isMonitoringEnabled {
                            userDefaults.set(dashboardLink, forKey: "NMDashboardLink")
                            userDefaults.set(dashboardAPIToken, forKey: "NMDashboardAPIToken")
                            dashboardViewModel.startMonitoring()
                        }
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
            }
        }
    }
}
