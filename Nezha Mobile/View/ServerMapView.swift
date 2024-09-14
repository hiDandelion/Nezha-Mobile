//
//  ServerMapView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/25/24.
//

import SwiftUI
import MapKit
import Cache

struct ServerCoordinate: Identifiable, Hashable {
    let id: UUID = UUID()
    var servers: [Server]
    let latitude: Double
    let longitude: Double
    let country: String?
    let city: String?
}

struct ServerMapView: View {
    @Environment(TabBarState.self) var tabBarState
    var servers: [Server]
    @State private var serverCoordinates: [ServerCoordinate] = []
    @State private var selectedCoordinate: ServerCoordinate?
    
    var body: some View {
        VStack {
            Map(selection: $selectedCoordinate) {
                ForEach(serverCoordinates) { serverCoordinate in
                    Marker(
                        serverCoordinate.servers.count <= 3 ?
                        serverCoordinate.servers
                            .sorted { server1, server2 in
                                switch (server1.displayIndex, server2.displayIndex) {
                                case (.none, .none):
                                    return server1.id < server2.id
                                case (.none, .some):
                                    return false
                                case (.some, .none):
                                    return true
                                case let (.some(index1), .some(index2)):
                                    return index1 > index2 || (index1 == index2 && server1.id < server2.id)
                                }
                            }
                            .compactMap { $0.name }
                            .joined(separator: "\n")
                        :
                            String(localized: "\(serverCoordinate.servers.count) servers")
                        ,
                        systemImage: "server.rack",
                        coordinate: CLLocationCoordinate2D(latitude: serverCoordinate.latitude, longitude: serverCoordinate.longitude)
                    )
                    .tag(serverCoordinate)
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
        }
        .toolbar(.hidden)
        .overlay {
            VStack {
                            HStack {
                                Spacer()
                                Button {
                                    serverCoordinates.removeAll()
                                    Task {
                                        await loadCoordinates()
                                    }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .padding(10)
                                        .foregroundStyle(.primary)
                                        .background(.thinMaterial)
                                        .clipShape(Circle())
                                        .padding()
                                        .hoverEffect(.lift)
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
            
            if let selectedCoordinate {
                VStack {
                    Spacer()
                    VStack {
                        Text(
                            selectedCoordinate.servers
                                .sorted { server1, server2 in
                                    switch (server1.displayIndex, server2.displayIndex) {
                                    case (.none, .none):
                                        return server1.id < server2.id
                                    case (.none, .some):
                                        return false
                                    case (.some, .none):
                                        return true
                                    case let (.some(index1), .some(index2)):
                                        return index1 > index2 || (index1 == index2 && server1.id < server2.id)
                                    }
                                }
                                .compactMap { $0.name }
                                .joined(separator: ", ")
                        )
                        if let city = selectedCoordinate.city {
                            Text(city)
                        }
                        if let country = selectedCoordinate.country {
                            Text(country)
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(minWidth: 200)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.thinMaterial)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            Task {
                await loadCoordinates()
            }
        }
        .onAppear {
            withAnimation {
                tabBarState.isMapViewVisible = true
            }
        }
        .onDisappear {
            withAnimation {
                tabBarState.isMapViewVisible = false
            }
        }
    }
    
    private func loadCoordinates() async {
        serverCoordinates.removeAll()
        
        let storage = try? Storage<String, IPCityData>(
            diskConfig: DiskConfig(name: "NMIPCityData"),
            memoryConfig: MemoryConfig(expiry: .never),
            fileManager: FileManager(),
            transformer: TransformerFactory.forCodable(ofType: IPCityData.self)
        )
        
        for server in servers {
            if let storage {
                if let currentIPCityData = try? storage.object(forKey: server.IPv4), let latitude = currentIPCityData.location.latitude, let longitude = currentIPCityData.location.longitude {
                    let existingServerCoordinateIndex = serverCoordinates.firstIndex(where: { $0.latitude == latitude && $0.longitude == longitude })
                    if let existingServerCoordinateIndex {
                        serverCoordinates[existingServerCoordinateIndex].servers.append(server)
                    }
                    else {
                        serverCoordinates.append(ServerCoordinate(servers: [server],latitude: latitude, longitude: longitude, country: currentIPCityData.country, city: currentIPCityData.city))
                    }
                }
                else {
                    if let response = try? await RequestHandler.getIPCityData(IP: server.IPv4, locale: Locale.preferredLanguages[0]), let currentIPCityData = response.result {
                        try? storage.setObject(currentIPCityData, forKey: server.IPv4)
                        if let latitude = currentIPCityData.location.latitude, let longitude = currentIPCityData.location.longitude {
                            let existingServerCoordinateIndex = serverCoordinates.firstIndex(where: { $0.latitude == latitude && $0.longitude == longitude })
                            if let existingServerCoordinateIndex {
                                serverCoordinates[existingServerCoordinateIndex].servers.append(server)
                            }
                            else {
                                serverCoordinates.append(ServerCoordinate(servers: [server],latitude: latitude, longitude: longitude, country: currentIPCityData.country, city: currentIPCityData.city))
                            }
                        }
                    }
                }
            }
        }
    }
}
