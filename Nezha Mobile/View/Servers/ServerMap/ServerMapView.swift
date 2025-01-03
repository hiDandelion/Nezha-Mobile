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
    var servers: [ServerData]
    let latitude: Double
    let longitude: Double
    let country: String?
    let city: String?
}

struct ServerMapView: View {
    @Environment(NMState.self) private var state
    @State private var serverCoordinates: [ServerCoordinate] = []
    @State private var selectedCoordinate: ServerCoordinate?
    let storage = try? Storage<String, GetIPCityDataResponse.IPCityData>(
        diskConfig: DiskConfig(name: "NMIPCityData"),
        memoryConfig: MemoryConfig(expiry: .never),
        fileManager: FileManager(),
        transformer: TransformerFactory.forCodable(ofType: GetIPCityDataResponse.IPCityData.self)
    )
    
    var body: some View {
        VStack {
            Map(selection: $selectedCoordinate) {
                ForEach(serverCoordinates) { serverCoordinate in
                    Marker(
                        serverCoordinate.servers.count <= 3 ?
                        serverCoordinate.servers
                            .sorted {
                                if $0.displayIndex == $1.displayIndex {
                                    return $0.serverID < $1.serverID
                                }
                                return $0.displayIndex > $1.displayIndex
                            }
                            .compactMap { $0.name }
                            .joined(separator: "\n")
                        :
                            String(localized: "\(serverCoordinate.servers.count) server(s)")
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
                        withAnimation {
                            state.isShowMapView = false
                        }
                    } label: {
                        Image(systemName: "xmark")
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
                                .sorted {
                                    if $0.displayIndex == $1.displayIndex {
                                        return $0.serverID < $1.serverID
                                    }
                                    return $0.displayIndex > $1.displayIndex
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
            }
        }
        .onAppear {
            Task {
                await loadCoordinates()
            }
        }
    }
    
    private func loadCoordinates() async {
        serverCoordinates.removeAll()
        
        for server in state.servers {
            if let storage {
                if let currentIPCityData = try? storage.object(forKey: server.ipv4), let latitude = currentIPCityData.location.latitude, let longitude = currentIPCityData.location.longitude {
                    let existingServerCoordinateIndex = serverCoordinates.firstIndex(where: { $0.latitude == latitude && $0.longitude == longitude })
                    if let existingServerCoordinateIndex {
                        serverCoordinates[existingServerCoordinateIndex].servers.append(server)
                    }
                    else {
                        serverCoordinates.append(ServerCoordinate(servers: [server],latitude: latitude, longitude: longitude, country: currentIPCityData.country, city: currentIPCityData.city))
                    }
                }
                else {
                    if let response = try? await RequestHandler.getIPCityData(IP: server.ipv4, locale: Locale.preferredLanguages[0]), let currentIPCityData = response.result {
                        try? storage.setObject(currentIPCityData, forKey: server.ipv4)
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
