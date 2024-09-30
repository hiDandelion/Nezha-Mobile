//
//  ReportDeviceInfoIntent.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/28/24.
//

#if os(iOS)
import AppIntents

struct ReportDeviceInfoIntent: AppIntent {
    static var title: LocalizedStringResource { "Report your device information." }
    
    func perform() async throws -> some IntentResult {
        let deviceModelIdentifier = DeviceInfo.getDeviceModelIdentifier()
        let OSVersionNumber = DeviceInfo.getOSVersionNumber()
        let cpuUsage = DeviceInfo.getCPUUsage()
        let memoryUsed = DeviceInfo.getMemoryUsed()
        let memoryTotal = DeviceInfo.getMemoryTotal()
        let diskUsed = DeviceInfo.getDiskUsed()
        let diskTotal = DeviceInfo.getDiskTotal()
        let bootTime = DeviceInfo.getBootTime()
        let uptime = DeviceInfo.getUptime()
        
        _ = try? await RequestHandler.reportDeviceInfo(identifier: deviceModelIdentifier, systemVersion: OSVersionNumber, memoryTotal: memoryTotal, diskTotal: diskTotal, bootTime: bootTime, agentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown", cpuUsage: cpuUsage, memoryUsed: memoryUsed, diskUsed: diskUsed, uptime: uptime, networkIn: 0, networkOut: 0, networkInSpeed: 0, networkOutSpeed: 0)
        
        return .result()
    }
}
#endif
