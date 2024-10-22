//
//  ReportDeviceInfoView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/26/24.
//

import SwiftUI

struct ReportDeviceInfoView: View {
    @AppStorage("NMDashboardGRPCLink", store: NMCore.userDefaults) private var dashboardGRPCLink: String = ""
    @AppStorage("NMDashboardGRPCPort", store: NMCore.userDefaults) private var dashboardGRPCPort: String = "5555"
    @State private var isReportingDeviceInfo: Bool = false
    @State private var reportDeviceInfoResponseSuccess: Bool?
    @State private var reportDeviceInfoErrorMessage: String = String(localized: "An error occurred")
    @State private var successHapticTrigger = false
    @State private var errorHapticTrigger = false
    
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
                    ZStack {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(.green)
                            Text("Successfully Reported")
                        }
                        .opacity(reportDeviceInfoResponseSuccess == true ? 1 : 0)
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.red)
                            Text(reportDeviceInfoErrorMessage)
                        }
                        .opacity(reportDeviceInfoResponseSuccess == false ? 1 : 0)
                    }
                }
                .sensoryFeedback(.success, trigger: successHapticTrigger)
                .sensoryFeedback(.error, trigger: errorHapticTrigger)
                
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
        _ = NMCore.debugLog("Get Device Info Info - Model Identifier: \(deviceModelIdentifier)")
        _ = NMCore.debugLog("Get Device Info Info - iOS Version: \(OSVersionNumber)")
        _ = NMCore.debugLog("Get Device Info Info - CPU Used: \(cpuUsage)")
        _ = NMCore.debugLog("Get Device Info Info - Memory Total: \(formatBytes(memoryTotal))")
        _ = NMCore.debugLog("Get Device Info Info - Memory Used: \(formatBytes(memoryUsed))")
        _ = NMCore.debugLog("Get Device Info Info - Disk Used: \(formatBytes(diskUsed))")
        _ = NMCore.debugLog("Get Device Info Info - Disk Total: \(formatBytes(diskTotal))")
        _ = NMCore.debugLog("Get Device Info Info - Boot Time: \(bootTime)")
        _ = NMCore.debugLog("Get Device Info Info - Up Time: \(uptime)")
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
                
                let reportDeviceHostResponse = try await RequestHandler.reportDeviceInfo(identifier: DeviceInfo.getDeviceModelIdentifier(), systemVersion: DeviceInfo.getOSVersionNumber(), memoryTotal: DeviceInfo.getMemoryTotal(), diskTotal: DeviceInfo.getDiskTotal(), bootTime: DeviceInfo.getBootTime(), agentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown", cpuUsage: DeviceInfo.getCPUUsage(), memoryUsed: DeviceInfo.getMemoryUsed(), diskUsed: DeviceInfo.getDiskUsed(), uptime: DeviceInfo.getUptime(), networkIn: dataUsageLaterReceived, networkOut: dataUsageLaterSent, networkInSpeed:  dataUsageLaterReceived - dataUsageFormerReceived, networkOutSpeed: dataUsageLaterSent - dataUsageFormerSent)
                
                if reportDeviceHostResponse.success {
                    withAnimation {
                        reportDeviceInfoResponseSuccess = true
                        successHapticTrigger.toggle()
                    }
                }
                else {
                    withAnimation {
                        reportDeviceInfoResponseSuccess = false
                        reportDeviceInfoErrorMessage = reportDeviceHostResponse.error ?? "Unknown Error"
                        errorHapticTrigger.toggle()
                    }
                }
                
                withAnimation {
                    isReportingDeviceInfo = false
                }
            }
            catch {
                withAnimation {
                    isReportingDeviceInfo = false
                    reportDeviceInfoErrorMessage = error.localizedDescription
                    errorHapticTrigger.toggle()
                }
            }
        }
    }
}
