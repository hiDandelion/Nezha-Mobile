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
    var server: GetServerDetailResponse.Server
    @State private var IPv4CityData: GetIPCityDataResponse.IPCityData?
    @State private var IPv6CityData: GetIPCityDataResponse.IPCityData?
    
    var body: some View {
        Section("Basic") {
            NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(server.name)"))
            NMUI.PieceOfInfo(systemImage: "cube", name: "ID", content: Text("\(server.id)"))
            NMUI.PieceOfInfo(systemImage: "tag", name: "Tag", content: Text("\(server.tag)"))
            
            if server.IPv4 != "" {
                if let cityData = IPv4CityData {
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
            
            if server.IPv6 != "" {
                if let cityData = IPv6CityData {
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
            NMUI.PieceOfInfo(systemImage: "clock", name: "Last Active", content: Text("\(convertTimestampToLocalizedDateString(timestamp: server.lastActive))"))
        }
        .onAppear {
            if server.IPv4 != "" {
                Task {
                    IPv4CityData = await getIPCityData(IP: server.IPv4)
                }
            }
            if server.IPv6 != "" {
                Task {
                    IPv6CityData = await getIPCityData(IP: server.IPv6)
                }
            }
        }
    }
    
    private var IPv4InfoLabel: some View {
        NMUI.PieceOfInfo(systemImage: "4.circle", name: "IPv4", content: Text("\(server.IPv4)"))
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    UIPasteboard.general.string = server.IPv4
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
#if os(iOS)
                NavigationLink(destination: PrepareConnectionView(host: server.IPv4)) {
                    Label("Connect", systemImage: "link")
                }
#endif
            }))
    }
    
    private var IPv6InfoLabel: some View {
        NMUI.PieceOfInfo(systemImage: "6.circle", name: "IPv6", content: Text("\(server.IPv6)"))
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    UIPasteboard.general.string = server.IPv6
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
#if os(iOS)
                NavigationLink(destination: PrepareConnectionView(host: server.IPv6)) {
                    Label("Connect", systemImage: "link")
                }
#endif
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
