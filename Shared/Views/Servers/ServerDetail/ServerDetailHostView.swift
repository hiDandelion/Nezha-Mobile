//
//  ServerDetailHostView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI

struct ServerDetailHostView: View {
    var server: ServerData
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Label("Operating System", systemImage: "opticaldisc")
                HStack {
                    let osName = server.host.platform
                    let osVersion = server.host.platformVersion
                    NMUI.getOSLogo(OSName: osName)
                    Text(osName == "" ? String(localized: "Unknown") : "\(osName.capitalizeFirstLetter()) \(osVersion)")
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading) {
                Label("CPU", systemImage: "cpu")
                HStack {
                    let mainCPUInfo = server.host.cpu.first
                    if let mainCPUInfo {
                        NMUI.getCPULogo(CPUName: mainCPUInfo)
                    }
                    Text(mainCPUInfo ?? String(localized: "N/A"))
                        .foregroundStyle(.secondary)
                }
            }
            
            NMUI.PieceOfInfo(systemImage: "triangle", name: "Architecture", content: Text("\(server.host.architecture)"))
            if server.host.virtualization != "" {
                NMUI.PieceOfInfo(systemImage: "cube.transparent", name: "Virtualization", content: Text("\(server.host.virtualization)"))
            }
        }
    }
}
