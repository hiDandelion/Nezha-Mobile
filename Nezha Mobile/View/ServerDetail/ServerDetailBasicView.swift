//
//  ServerDetailBasicView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/11/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ServerDetailBasicView: View {
    var server: Server
    @State private var IPv4CityData: GetIPCityDataResponse?
    @State private var IPv6CityData: GetIPCityDataResponse?
    
    var body: some View {
        Section("Basic") {
            pieceOfInfo(systemImage: "cube", name: "ID", content: "\(server.id)")
            pieceOfInfo(systemImage: "tag", name: "Tag", content: "\(server.tag)")
            
            if let cityData = IPv4CityData?.result {
                DisclosureGroup {
                    pieceOfInfo(systemImage: nil, name: "Continent", content: "\(cityData.continent)")
                    pieceOfInfo(systemImage: nil, name: "Country", content: "\(cityData.country)")
                    pieceOfInfo(systemImage: nil, name: "Registered Country", content: "\(cityData.registeredCountry)")
                    pieceOfInfo(systemImage: nil, name: "City", content: "\(cityData.city)")
                    pieceOfInfo(systemImage: nil, name: "Time Zone", content: "\(cityData.location.timezone)")
                } label: {
                    pieceOfInfo(systemImage: "4.circle", name: "IPv4", content: "\(server.IPv4)")
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }))
                }
            }
            else if server.IPv4 != "" {
                pieceOfInfo(systemImage: "4.circle", name: "IPv4", content: "\(server.IPv4)")
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            UIPasteboard.general.setValue(server.IPv4, forPasteboardType: UTType.plainText.identifier)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }))
            }
            
            if server.IPv6 != "", let cityData = IPv6CityData?.result {
                DisclosureGroup {
                    pieceOfInfo(systemImage: nil, name: "Continent", content: "\(cityData.continent)")
                    pieceOfInfo(systemImage: nil, name: "Country", content: "\(cityData.country)")
                    pieceOfInfo(systemImage: nil, name: "Registered Country", content: "\(cityData.registeredCountry)")
                    pieceOfInfo(systemImage: nil, name: "City", content: "\(cityData.city)")
                    pieceOfInfo(systemImage: nil, name: "Time Zone", content: "\(cityData.location.timezone)")
                } label: {
                    pieceOfInfo(systemImage: "6.circle", name: "IPv6", content: "\(server.IPv6)")
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }))
                }
            }
            else if server.IPv6 != "" {
                pieceOfInfo(systemImage: "6.circle", name: "IPv6", content: "\(server.IPv6)")
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            UIPasteboard.general.setValue(server.IPv6, forPasteboardType: UTType.plainText.identifier)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }))
            }
            
            pieceOfInfo(systemImage: "power", name: "Up Time", content: "\(formatTimeInterval(seconds: server.status.uptime))")
            pieceOfInfo(systemImage: "clock", name: "Last Active", content: "\(convertTimestampToLocalizedDateString(timestamp: server.lastActive))")
        }
        .onAppear {
            if server.IPv4 != "" {
                Task {
                    IPv4CityData = try? await RequestHandler.getIPCityData(IP: server.IPv4, locale: Locale.preferredLanguages[0])
                }
            }
            if server.IPv6 != "" {
                Task {
                    IPv6CityData = try? await RequestHandler.getIPCityData(IP: server.IPv6, locale: Locale.preferredLanguages[0])
                }
            }
        }
    }
}
