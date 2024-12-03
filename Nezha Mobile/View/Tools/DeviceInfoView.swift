//
//  DeviceInfoView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 10/5/24.
//

import SwiftUI

struct DeviceInfoView: View {
    @Environment(\.scenePhase) private var scenePhase
    private var deviceInfoViewModel: DeviceInfoViewModel = DeviceInfoViewModel()
    
    var body: some View {
        List {
            NMUI.PieceOfInfo(systemImage: "iphone", name: "Model Identifier", content: Text("\(deviceInfoViewModel.deviceModelIdentifier)"))
            NMUI.PieceOfInfo(systemImage: "123.rectangle", name: "System Version", content: Text("\(deviceInfoViewModel.OSVersionNumber)"))
            
            let gaugeGradient = Gradient(colors: [.green, .pink])
            
            VStack {
                HStack {
                    Label("CPU", systemImage: "cpu")
                    Spacer()
                    Text("\(deviceInfoViewModel.cpuUsage, specifier: "%.2f")%")
                        .foregroundStyle(.secondary)
                }
                
                let cpuUsage = deviceInfoViewModel.cpuUsage / 100
                Gauge(value: cpuUsage) {
                    
                }
                .gaugeStyle(.linearCapacity)
                .tint(gaugeGradient)
            }
            
            VStack {
                HStack {
                    Label("Memory", systemImage: "memorychip")
                    Spacer()
                    Text("\(formatBytes(deviceInfoViewModel.memoryUsed))/\(formatBytes(deviceInfoViewModel.memoryTotal))")
                        .foregroundStyle(.secondary)
                }
                
                let memoryUsage = (deviceInfoViewModel.memoryTotal == 0 ? 0 : Double(deviceInfoViewModel.memoryUsed) / Double(deviceInfoViewModel.memoryTotal))
                Gauge(value: memoryUsage) {
                    
                }
                .gaugeStyle(.linearCapacity)
                .tint(gaugeGradient)
            }
            
            VStack {
                HStack {
                    Label("Disk", systemImage: "internaldrive")
                    Spacer()
                    Text("\(formatBytes(deviceInfoViewModel.diskUsed))/\(formatBytes(deviceInfoViewModel.diskTotal))")
                        .foregroundStyle(.secondary)
                }
                
                let diskUsage = (deviceInfoViewModel.diskTotal == 0 ? 0 : Double(deviceInfoViewModel.diskUsed) / Double(deviceInfoViewModel.diskTotal))
                Gauge(value: diskUsage) {
                    
                }
                .gaugeStyle(.linearCapacity)
                .tint(gaugeGradient)
            }
            
            NMUI.PieceOfInfo(systemImage: "network", name: "Network Send/Receive", content: Text("↓ \(formatBytes(deviceInfoViewModel.networkInSpeed))/s ↑ \(formatBytes(deviceInfoViewModel.networkOutSpeed))/s"))
            NMUI.PieceOfInfo(systemImage: "circle.dotted.circle", name: "Network Data", content: Text("↓ \(formatBytes(deviceInfoViewModel.networkIn)) ↑ \(formatBytes(deviceInfoViewModel.networkOut))"))
        }
        .navigationTitle("Device Info")
        .onAppear {
            deviceInfoViewModel.startMonitoring()
        }
        .onDisappear {
            deviceInfoViewModel.stopMonitoring()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                deviceInfoViewModel.startMonitoring()
            }
            else {
                deviceInfoViewModel.stopMonitoring()
            }
        }
    }
}
