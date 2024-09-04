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
    var server: Server
    @State private var IPv4CityData: IPCityData?
    @State private var IPv6CityData: IPCityData?
    
    var body: some View {
        Section("Basic") {
            pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
            pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
            
            if server.IPv4 != "" {
                if let cityData = IPv4CityData {
                    DisclosureGroup {
                        pieceOfInfo(systemImage: nil, name: "Continent", content: "\(cityData.continent)")
                        pieceOfInfo(systemImage: nil, name: "Country", content: "\(cityData.country)")
                        pieceOfInfo(systemImage: nil, name: "Registered Country", content: "\(cityData.registeredCountry)")
                        pieceOfInfo(systemImage: nil, name: "City", content: "\(cityData.city)")
                        pieceOfInfo(systemImage: nil, name: "Time Zone", content: "\(cityData.location.timezone)")
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
                        pieceOfInfo(systemImage: nil, name: "Continent", content: "\(cityData.continent)")
                        pieceOfInfo(systemImage: nil, name: "Country", content: "\(cityData.country)")
                        pieceOfInfo(systemImage: nil, name: "Registered Country", content: "\(cityData.registeredCountry)")
                        pieceOfInfo(systemImage: nil, name: "City", content: "\(cityData.city)")
                        pieceOfInfo(systemImage: nil, name: "Time Zone", content: "\(cityData.location.timezone)")
                    } label: {
                        IPv6InfoLabel
                    }
                }
                else {
                    IPv6InfoLabel
                }
            }
            
            pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
            pieceOfInfo(systemImage: "clock", name: "Last Active", content: "\(convertTimestampToLocalizedDateString(timestamp: server.lastActive))")
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
        pieceOfInfo(systemImage: "4.circle", name: "IPv4", content: "\(server.IPv4)")
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                NavigationLink(destination: PrepareConnectionView(host: server.IPv4)) {
                    Label("Connect", systemImage: "link")
                }
            }))
    }
    
    private var IPv6InfoLabel: some View {
        pieceOfInfo(systemImage: "6.circle", name: "IPv6", content: "\(server.IPv6)")
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                NavigationLink(destination: PrepareConnectionView(host: server.IPv6)) {
                    Label("Connect", systemImage: "link")
                }
            }))
    }
    
    private func getIPCityData(IP: String) async -> IPCityData? {
        var currentIPCityData: IPCityData?
        
        let storage = try? Storage<String, IPCityData>(
            diskConfig: DiskConfig(name: "NMIPCityData"),
            memoryConfig: MemoryConfig(expiry: .never),
            fileManager: FileManager(),
            transformer: TransformerFactory.forCodable(ofType: IPCityData.self)
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
