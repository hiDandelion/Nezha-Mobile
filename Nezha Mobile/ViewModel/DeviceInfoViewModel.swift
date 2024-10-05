//
//  DeviceInfoViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/5/24.
//

import Foundation
import SwiftUI

@Observable
class DeviceInfoViewModel {
    private var timer: Timer?
    let deviceModelIdentifier: String = DeviceInfo.getDeviceModelIdentifier()
    let OSVersionNumber: String = DeviceInfo.getOSVersionNumber()
    var cpuUsage: Double = DeviceInfo.getCPUUsage()
    var memoryUsed: Int64 = DeviceInfo.getMemoryUsed()
    let memoryTotal: Int64 = DeviceInfo.getMemoryTotal()
    var diskUsed: Int64 = DeviceInfo.getDiskUsed()
    let diskTotal: Int64 = DeviceInfo.getDiskTotal()
    let bootTime: Int64 = DeviceInfo.getBootTime()
    var uptime: Int64 = DeviceInfo.getUptime()
    var networkIn: Int64 = 0
    var networkOut: Int64 = 0
    var networkInSpeed: Int64 = 0
    var networkOutSpeed: Int64 = 0
    
    init() {
        startMonitoring()
        refreshDeviceInfo()
    }
    
    func startMonitoring() {
        stopMonitoring()
        startTimer()
    }
    
    func stopMonitoring() {
        stopTimer()
    }
    
    func refreshDeviceInfo() {
        withAnimation {
            cpuUsage = DeviceInfo.getCPUUsage()
            memoryUsed = DeviceInfo.getMemoryUsed()
            diskUsed = DeviceInfo.getDiskUsed()
            uptime = DeviceInfo.getUptime()
        }
        
        Task {
            let dataUsageFormer = DeviceInfo.getDataUsage()
            let dataUsageFormerReceived = dataUsageFormer.wifiReceived + dataUsageFormer.wirelessWanDataReceived
            let dataUsageFormerSent = dataUsageFormer.wifiSent + dataUsageFormer.wirelessWanDataSent
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            let dataUsageLater = DeviceInfo.getDataUsage()
            let dataUsageLaterReceived = dataUsageLater.wifiReceived + dataUsageLater.wirelessWanDataReceived
            let dataUsageLaterSent = dataUsageLater.wifiSent + dataUsageLater.wirelessWanDataSent
            
            withAnimation {
                networkIn = dataUsageLaterReceived
                networkOut = dataUsageLaterSent
                networkInSpeed = dataUsageLaterReceived - dataUsageFormerReceived
                networkOutSpeed = dataUsageLaterSent - dataUsageFormerSent
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                refreshDeviceInfo()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
