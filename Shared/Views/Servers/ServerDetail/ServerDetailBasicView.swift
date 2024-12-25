//
//  ServerDetailBasicView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI
import UniformTypeIdentifiers
import Cache

struct ServerDetailBasicView: View {
    var server: ServerData
    @State private var ipv4CityData: GetIPCityDataResponse.IPCityData?
    @State private var ipv6CityData: GetIPCityDataResponse.IPCityData?
    
    var body: some View {
        Section {
            NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(server.name)"))
            NMUI.PieceOfInfo(systemImage: "cube", name: "ID", content: Text("\(server.serverID)"))
            
            if server.ipv4 != "" {
                if let cityData = ipv4CityData {
                    DisclosureGroup {
                        NMUI.PieceOfInfo(systemImage: nil, name: "Continent", content: Text("\(cityData.continent)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Country", content: Text("\(cityData.country)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Registered Country", content: Text("\(cityData.registeredCountry)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "City", content: Text("\(cityData.city)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Time Zone", content: Text("\(cityData.location.timezone)"))
                    } label: {
                        IPv4InfoLabel
                    }
                }
                else {
                    IPv4InfoLabel
                }
            }
            
            if server.ipv6 != "" {
                if let cityData = ipv6CityData {
                    DisclosureGroup {
                        NMUI.PieceOfInfo(systemImage: nil, name: "Continent", content: Text("\(cityData.continent)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Country", content: Text("\(cityData.country)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Registered Country", content: Text("\(cityData.registeredCountry)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "City", content: Text("\(cityData.city)"))
                        NMUI.PieceOfInfo(systemImage: nil, name: "Time Zone", content: Text("\(cityData.location.timezone)"))
                    } label: {
                        IPv6InfoLabel
                    }
                }
                else {
                    IPv6InfoLabel
                }
            }
            
            NMUI.PieceOfInfo(systemImage: "power", name: "Up Time", content: Text("\(formatTimeInterval(seconds: server.status.uptime))"))
            NMUI.PieceOfInfo(systemImage: "clock", name: "Last Active", content: Text(server.lastActive, format: Date.FormatStyle(date: .complete, time: .standard)))
        }
        .onAppear {
            if server.ipv4 != "" {
                Task {
                    ipv4CityData = await getIPCityData(IP: server.ipv4)
                }
            }
            if server.ipv6 != "" {
                Task {
                    ipv6CityData = await getIPCityData(IP: server.ipv6)
                }
            }
        }
    }
    
    private var IPv4InfoLabel: some View {
        NMUI.PieceOfInfo(systemImage: "4.circle", name: "IPv4", content: Text("\(server.ipv4)"))
            .contextMenu(ContextMenu(menuItems: {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = server.ipv4
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(server.ipv4, forType: .string)
#endif
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }))
    }
    
    private var IPv6InfoLabel: some View {
        NMUI.PieceOfInfo(systemImage: "6.circle", name: "IPv6", content: Text("\(server.ipv6)"))
            .contextMenu(ContextMenu(menuItems: {
                Button {
#if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = server.ipv6
#endif
#if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(server.ipv6, forType: .string)
#endif
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }))
    }
    
    private func getIPCityData(IP: String) async -> GetIPCityDataResponse.IPCityData? {
        var currentIPCityData: GetIPCityDataResponse.IPCityData?
        
        let storage = try? Storage<String, GetIPCityDataResponse.IPCityData>(
            diskConfig: DiskConfig(name: "NMIPCityData"),
            memoryConfig: MemoryConfig(expiry: .never),
            fileManager: FileManager(),
            transformer: TransformerFactory.forCodable(ofType: GetIPCityDataResponse.IPCityData.self)
        )
        
        if let storage {
            currentIPCityData = try? storage.object(forKey: IP)
        }
        
        if currentIPCityData == nil {
            let response = try? await RequestHandler.getIPCityData(IP: IP, locale: Locale.preferredLanguages[0])
            currentIPCityData = response?.result
            
            if let storage, let currentIPCityData {
                try? storage.setObject(currentIPCityData, forKey: IP)
            }
        }
        
        return currentIPCityData
    }
}
