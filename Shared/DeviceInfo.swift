//
//  DeviceInfo.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/26/24.
//

#if os(iOS) || os(visionOS)
import Foundation
import UIKit

class DeviceInfo {
    static func getDeviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    static func getOSVersionNumber() -> String {
        return UIDevice.current.systemVersion as String
    }
    
    static func getCPUUsage() -> Double {
        var status: kern_return_t
        var task_info_count: mach_msg_type_number_t
        task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
        status = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
        if status != KERN_SUCCESS {
            return 0.0
        }
        
        var thread_list: thread_act_array_t?
        var thread_count: mach_msg_type_number_t = 0
        defer {
            if let thread_list = thread_list {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: thread_list), vm_size_t(thread_count) * vm_size_t(MemoryLayout<thread_act_t>.stride))
            }
        }
        
        status = task_threads(mach_task_self_, &thread_list, &thread_count)
        if status != KERN_SUCCESS {
            return 0.0
        }
        
        var total_cpu: Double = 0
        
        if let thread_list = thread_list {
            for j in 0 ..< Int(thread_count) {
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
                status = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                                     &thinfo, &thread_info_count)
                if status != KERN_SUCCESS {
                    return 0.0
                }
                
                let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)
                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    total_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            }
        }
        
        return total_cpu
    }
    
    static func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
        var result = thread_basic_info()
        
        result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
        result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
        result.cpu_usage = threadInfo[4]
        result.policy = threadInfo[5]
        result.run_state = threadInfo[6]
        result.flags = threadInfo[7]
        result.suspend_count = threadInfo[8]
        result.sleep_time = threadInfo[9]
        
        return result
    }
    
    static func getMemoryTotal() -> Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }
    
    static func getMemoryUsed() -> Int64 {
        let hostPort: mach_port_t = mach_host_self()
        var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        var pagesize: vm_size_t = 0
        host_page_size(hostPort, &pagesize)
        var vmStat: vm_statistics = vm_statistics_data_t()
        let capacity = MemoryLayout.size(ofValue: vmStat) / MemoryLayout<Int32>.stride
        let status: kern_return_t = withUnsafeMutableBytes(of: &vmStat) {
            let boundPtr = $0.baseAddress?.bindMemory(to: Int32.self, capacity: capacity)
            return host_statistics(hostPort, HOST_VM_INFO, boundPtr, &host_size)
        }
        
        if status == KERN_SUCCESS {
            let total_memory = getMemoryTotal()
            let free_memory = (Int64)((vm_size_t)(vmStat.free_count) * pagesize)
            return total_memory - free_memory
        }
        else {
            return 0
        }
    }
    
    static func getDiskTotal() -> Int64 {
        let fileManager = FileManager.default
        guard let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: "/") else {
            return 0
        }
        
        return Int64((systemAttributes[.systemSize] as? NSNumber)?.int64Value ?? 0)
    }
    
    static func getDiskUsed() -> Int64 {
        let fileManager = FileManager.default
        guard let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: "/") else {
            return 0
        }
        
        let totalBytes = (systemAttributes[.systemSize] as? NSNumber)?.int64Value ?? 0
        let freeBytes = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        
        return Int64(totalBytes - freeBytes)
    }
    
    static func getBootTime() -> Int64 {
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        
        let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
        if result != 0 {
            return 0
        }
        
        return Int64(boottime.tv_sec)
    }
    
    static func getUptime() -> Int64 {
        return Int64(ProcessInfo.processInfo.systemUptime)
    }
}

/// Data usage

class DataUsageInfo {
    var wifiReceived: Int64 = 0
    var wifiSent: Int64 = 0
    var wirelessWanDataReceived: Int64 = 0
    var wirelessWanDataSent: Int64 = 0

    func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}

extension DeviceInfo {
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    
    static func getDataUsage() -> DataUsageInfo {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil
        
        let dataUsageInfo = DataUsageInfo()
        
        guard getifaddrs(&interfaceAddresses) == 0 else { return dataUsageInfo }
        
        var pointer = interfaceAddresses
        while pointer != nil {
            guard let info = getDataUsageInfo(from: pointer!) else {
                pointer = pointer!.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info: info)
            pointer = pointer!.pointee.ifa_next
        }
        
        freeifaddrs(interfaceAddresses)
        
        return dataUsageInfo
    }
    
    private class func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer
        
        let name: String! = String(cString: infoPointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }
        
        return dataUsageInfo(from: pointer, name: name)
    }
    
    private class func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>? = nil
        let dataUsageInfo = DataUsageInfo()
        
        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wifiSent += Int64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wifiReceived += Int64(networkData?.pointee.ifi_ibytes ?? 0)
        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wirelessWanDataSent += Int64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wirelessWanDataReceived += Int64(networkData?.pointee.ifi_ibytes ?? 0)
        }
        
        return dataUsageInfo
    }
}
#endif
