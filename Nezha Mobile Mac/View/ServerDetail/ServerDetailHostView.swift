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
                    if OSName.contains("debian") {
                        Image("DebianLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    if OSName.contains("ubuntu") {
                        Image("UbuntuLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    if OSName.contains("darwin") {
                        Image("macOSLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    Text(OSName == "" ? String(localized: "Unknown") : "\(OSName.capitalizeFirstLetter()) \(OSVersion)")
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading) {
                Label("CPU", systemImage: "cpu")
                HStack {
                    let mainCPUInfo = server.host.cpu?.first
                    if let mainCPUInfo, mainCPUInfo.contains("AMD") {
                        Image("AMDLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    if let mainCPUInfo, mainCPUInfo.contains("Intel") {
                        Image("IntelLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    if let mainCPUInfo, mainCPUInfo.contains("Neoverse") {
                        Image("ARMLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    if let mainCPUInfo, mainCPUInfo.contains("Apple") {
                        Image("AppleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50)
                    }
                    Text(mainCPUInfo ?? String(localized: "N/A"))
                        .foregroundStyle(.secondary)
                }
            }
            
            if let mainGPUInfo = server.host.gpu?.first {
                pieceOfInfo(systemImage: "cpu.fill", name: "GPU", content: Text("\(mainGPUInfo)"))
            }
            
            pieceOfInfo(systemImage: "triangle", name: "Architecture", content: Text("\(server.host.arch)"))
            pieceOfInfo(systemImage: "cube.transparent", name: "Virtualization", content: Text("\(server.host.virtualization == "" ? String(localized: "Unknown") : server.host.virtualization)"))
            pieceOfInfo(systemImage: "rectangle.2.swap", name: "Agent", content: Text("\(server.host.version)"))
        }
    }
}
