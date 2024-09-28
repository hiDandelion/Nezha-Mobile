//
//  ReportDeviceInfoView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/26/24.
//

import SwiftUI

struct ReportDeviceInfoView: View {
    @AppStorage("NMDashboardGRPCLink", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardGRPCLink: String = ""
    @AppStorage("NMDashboardGRPCPort", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var dashboardGRPCPort: String = "5555"
    @State private var isShowPrivacyNotice: Bool = false
    @State private var isReportingDeviceInfo: Bool = false
    @State private var reportDeviceHostResponseSuccess: Bool = false
    @State private var reportDeviceStatusResponseSuccess: Bool = false
    @State private var reportDeviceInfoErrorMessage: String = ""
    
    var body: some View {
        if dashboardGRPCLink != "", dashboardGRPCPort != "" {
            VStack {
                Spacer()
                
                VStack {
                    Image(systemName: "cloud")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue)
                        .frame(width: 100, height: 100)
                    Text("\(dashboardGRPCLink):\(dashboardGRPCPort)")
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                        Text("Successfully Reported")
                    }
                    .opacity(reportDeviceHostResponseSuccess && reportDeviceHostResponseSuccess ? 1 : 0)
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.red)
                        Text(reportDeviceInfoErrorMessage)
                    }
                    .opacity(reportDeviceInfoErrorMessage != "" ? 1 : 0)
                }
                
                Spacer()
                
                ZStack {
                    Button {
                        reportDeviceInfo()
                    } label: {
                        Image(systemName: "arrowshape.up.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .opacity(isReportingDeviceInfo ? 0 : 1)
                    
                    ProgressView("Reporting")
                        .opacity(isReportingDeviceInfo ? 1 : 0)
                }
                
                Spacer()
                
                Button {
                    isShowPrivacyNotice = true
                } label: {
                    Text("Privacy Notice")
                        .font(.caption)
                }
                .sheet(isPresented: $isShowPrivacyNotice) {
                    NavigationStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("By using Nezha Mobile as an agent, you acknowledge we will collect the following matrix of your device:")
                                Text("- OS Version\n- Model Identifier\n- CPU Usage\n- Memory Usage\n- Disk Usage\n- Data Usage\n- Boot Time\n- Uptime")
                                Text("These data will only be uploaded to the server you configured. We will not save your data.")
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .navigationTitle("Privacy Notice")
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    isShowPrivacyNotice = false
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            NavigationLink("Set up Agent") {
                AgentSettingsView()
            }
        }
    }
    
    private func reportDeviceInfo() {
        let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
        let OSVersionNumber = DeviceInfo.getOSVersionNumber()
        let cpuUsage = DeviceInfo.getCPUUsage()
        let memoryUsed = DeviceInfo.getMemoryUsed()
        let memoryTotal = DeviceInfo.getMemoryTotal()
        let diskUsed = DeviceInfo.getDiskUsed()
        let diskTotal = DeviceInfo.getDiskTotal()
        let bootTime = DeviceInfo.getBootTime()
        let uptime = DeviceInfo.getUptime()
#if DEBUG
        _ = debugLog("Get Device Info Info - Model Identifier: \(deviceModelIdentifier)")
        _ = debugLog("Get Device Info Info - iOS Version: \(OSVersionNumber)")
        _ = debugLog("Get Device Info Info - CPU Used: \(cpuUsage)")
        _ = debugLog("Get Device Info Info - Memory Total: \(formatBytes(memoryTotal))")
        _ = debugLog("Get Device Info Info - Memory Used: \(formatBytes(memoryUsed))")
        _ = debugLog("Get Device Info Info - Disk Used: \(formatBytes(diskUsed))")
        _ = debugLog("Get Device Info Info - Disk Total: \(formatBytes(diskTotal))")
        _ = debugLog("Get Device Info Info - Boot Time: \(bootTime)")
        _ = debugLog("Get Device Info Info - Up Time: \(uptime)")
#endif
        
        isReportingDeviceInfo = true
        Task {
            do {
                let dataUsageFormer = DeviceInfo.getDataUsage()
                let dataUsageFormerReceived = dataUsageFormer.wifiReceived + dataUsageFormer.wirelessWanDataReceived
                let dataUsageFormerSent = dataUsageFormer.wifiSent + dataUsageFormer.wirelessWanDataSent
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                let dataUsageLater = DeviceInfo.getDataUsage()
                let dataUsageLaterReceived = dataUsageLater.wifiReceived + dataUsageLater.wirelessWanDataReceived
                let dataUsageLaterSent = dataUsageLater.wifiSent + dataUsageLater.wirelessWanDataSent
                
                let reportDeviceHostResponse = try await RequestHandler.reportDeviceHost(identifier: DeviceInfo.getDeviceModelIdentifier(), systemVersion: DeviceInfo.getOSVersionNumber(), memoryTotal: DeviceInfo.getMemoryTotal(), diskTotal: DeviceInfo.getDiskTotal(), bootTime: DeviceInfo.getBootTime(), agentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                if reportDeviceHostResponse.success {
                    withAnimation {
                        reportDeviceHostResponseSuccess = true
                    }
                }
                else {
                    reportDeviceHostResponseSuccess = false
                    reportDeviceInfoErrorMessage = reportDeviceHostResponse.error ?? "Unknown Error"
                }
                
                let reportDeviceStatusResponse = try await RequestHandler.reportDeviceStatus(
                    cpuUsage: DeviceInfo.getCPUUsage(),
                    memoryUsed: DeviceInfo.getMemoryUsed(),
                    diskUsed: DeviceInfo.getDiskUsed(),
                    uptime: DeviceInfo.getUptime(),
                    networkIn: dataUsageLaterReceived,
                    networkOut: dataUsageLaterSent,
                    networkInSpeed:  dataUsageLaterReceived - dataUsageFormerReceived,
                    networkOutSpeed: dataUsageLaterSent - dataUsageFormerSent
                )
                if reportDeviceStatusResponse.success {
                    withAnimation {
                        reportDeviceStatusResponseSuccess = true
                    }
                }
                else {
                    reportDeviceStatusResponseSuccess = false
                    reportDeviceInfoErrorMessage = reportDeviceHostResponse.error ?? "Unknown Error"
                }
                
                isReportingDeviceInfo = false
            }
            catch {
                reportDeviceInfoErrorMessage = error.localizedDescription
                
                isReportingDeviceInfo = false
            }
        }
    }
}
