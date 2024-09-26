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
                    if isReportingDeviceInfo {
                        ProgressView("Reporting")
                    }
                    else {
                        if reportDeviceHostResponseSuccess, reportDeviceHostResponseSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.green)
                                Text("Successfully Reported")
                            }
                        }
                        else if reportDeviceInfoErrorMessage != "" {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.red)
                                Text(reportDeviceInfoErrorMessage)
                            }
                        }
                    }
                }
                .frame(minHeight: 300)
                
                Spacer()
                
                Button {
                    _ = debugLog("Get Device Info Info - Model Identifier: \(getDeviceModelIdentifier())")
                    _ = debugLog("Get Device Info Info - iOS Version: \(getiOSVersionNumber())")
                    _ = debugLog("Get Device Info Info - Memory Used: \(formatBytes(getMemoryUsed()))")
                    _ = debugLog("Get Device Info Info - Disk Used: \(formatBytes(getDiskUsed()))")
                    _ = debugLog("Get Device Info Info - Disk Total: \(formatBytes(getDiskTotal()))")
                    _ = debugLog("Get Device Info Info - Boot Time: \(getBootTime())")
                    _ = debugLog("Get Device Info Info - Up Time: \(getUptime())")
                    
                    isReportingDeviceInfo = true
                    Task {
                        do {
                            let reportDeviceHostResponse = try await RequestHandler.reportDeviceHost(identifier: getDeviceModelIdentifier(), systemVersion: getiOSVersionNumber(), diskTotal: getDiskTotal(), bootTime: getBootTime())
                            if reportDeviceHostResponse.success {
                                reportDeviceHostResponseSuccess = true
                                reportDeviceInfoErrorMessage = reportDeviceHostResponse.error ?? "Unknown Error"
                            }
                            else {
                                reportDeviceHostResponseSuccess = false
                            }
                            
                            let reportDeviceStatusResponse = try await RequestHandler.reportDeviceStatus(memoryUsed: getMemoryUsed(), diskUsed: getDiskUsed(), uptime: getUptime())
                            if reportDeviceStatusResponse.success {
                                reportDeviceStatusResponseSuccess = true
                                reportDeviceInfoErrorMessage = reportDeviceHostResponse.error ?? "Unknown Error"
                            }
                            
                            isReportingDeviceInfo = false
                        }
                        catch {
                            reportDeviceInfoErrorMessage = error.localizedDescription
                            
                            isReportingDeviceInfo = false
                        }
                    }
                    
                } label: {
                    Image(systemName: "arrowshape.up.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 100, height: 100)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button {
                    isShowPrivacyNotice = true
                } label: {
                    Text("Privacy Notice")
                        .font(.caption)
                }
                .alert(
                    "Privacy Notice",
                    isPresented: $isShowPrivacyNotice,
                    actions: {
                        Button("OK") {
                            isShowPrivacyNotice = false
                        }
                    },
                    message: {
                        Text("By using Nezha Mobile as an agent, we will collect matrix of your device including memory usage, disk usage and uptime. These data will only be uploaded to the server you configured. We will not save your data.")
                    }
                )
            }
        }
        else {
            NavigationLink("Set up Agent") {
                AgentSettingsView()
            }
        }
    }
    
    private func getDeviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private func getiOSVersionNumber() -> String {
        return UIDevice.current.systemVersion as String
    }
    
    private func getMemoryUsed() -> Int64 {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(taskInfo.resident_size)
        } else {
            return 0
        }
    }
    
    private func getDiskTotal() -> Int64 {
        let fileManager = FileManager.default
        guard let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: "/") else {
            return 0
        }
        
        return Int64((systemAttributes[.systemSize] as? NSNumber)?.int64Value ?? 0)
    }
    
    private func getDiskUsed() -> Int64 {
        let fileManager = FileManager.default
        guard let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: "/") else {
            return 0
        }
        
        let totalBytes = (systemAttributes[.systemSize] as? NSNumber)?.int64Value ?? 0
        let freeBytes = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        
        return Int64(totalBytes - freeBytes)
    }
    
    private func getBootTime() -> Int64 {
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        
        let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
        if result != 0 {
            return 0
        }
        
        return Int64(boottime.tv_sec)
    }
    
    private func getUptime() -> Int64 {
        return Int64(ProcessInfo.processInfo.systemUptime)
    }
}
