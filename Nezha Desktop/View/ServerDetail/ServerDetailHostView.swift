//
//  ServerDetailHostView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailHostView: View {
    var server: Server
    
    var body: some View {
        Section("Host") {
            VStack(alignment: .leading) {
                Label("Operating System", systemImage: "opticaldisc")
                HStack {
                    let OSName = server.host.platform
                    let OSVersion = server.host.platformVersion
                    OSImage(OSName: OSName)
                    Text(OSName == "" ? String(localized: "Unknown") : "\(OSName.capitalizeFirstLetter()) \(OSVersion)")
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading) {
                Label("CPU", systemImage: "cpu")
                HStack {
                    let mainCPUInfo = server.host.cpu?.first
                    if let mainCPUInfo {
                        CPUImage(CPUName: mainCPUInfo)
                    }
                    Text(mainCPUInfo ?? String(localized: "N/A"))
                        .foregroundStyle(.secondary)
                }
            }
            
            if let mainGPUInfo = server.host.gpu?.first {
                VStack(alignment: .leading) {
                    Label("GPU", systemImage: "cpu.fill")
                    HStack {
                        GPUImage(GPUName: mainGPUInfo)
                        Text(mainGPUInfo)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            PieceOfInfo(systemImage: "triangle", name: "Architecture", content: Text("\(server.host.arch)"))
            if server.host.virtualization != "" {
                PieceOfInfo(systemImage: "cube.transparent", name: "Virtualization", content: Text("\(server.host.virtualization)"))
            }
            PieceOfInfo(systemImage: "rectangle.2.swap", name: "Agent", content: Text("\(server.host.version)"))
        }
    }
}
