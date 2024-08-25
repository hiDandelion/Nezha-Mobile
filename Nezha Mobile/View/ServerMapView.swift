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
    let name: String
    let latitude: Double
    let longitude: Double
}

@available(iOS 17.0, *)
struct ServerMapView: View {
    @Binding var isShowingServerMapView: Bool
    var servers: [Server]
    @State private var serverCoordinates: [ServerCoordinate] = []
    @State private var selectedCoordinate: ServerCoordinate?
    
    var body: some View {
        VStack {
            Map(selection: $selectedCoordinate) {
                ForEach(serverCoordinates) { serverCoordinate in
                    Marker(serverCoordinate.name, systemImage: "server.rack", coordinate: CLLocationCoordinate2D(latitude: serverCoordinate.latitude, longitude: serverCoordinate.longitude))
                        .tag(serverCoordinate)
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
        }
        .overlay {
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            isShowingServerMapView = false
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
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            Task {
                let storage = try? Storage<String, IPCityData>(
                    diskConfig: DiskConfig(name: "NMIPCityData"),
                    memoryConfig: MemoryConfig(expiry: .never),
                    fileManager: FileManager(),
                    transformer: TransformerFactory.forCodable(ofType: IPCityData.self)
                )
                
                for server in servers {
                    if let storage {
                        if let currentIPCityData = try? storage.object(forKey: server.IPv4), let latitude = currentIPCityData.location.latitude, let longitude = currentIPCityData.location.longitude {
                            serverCoordinates.append(ServerCoordinate(name: server.name,latitude: latitude, longitude: longitude))
                        }
                        else {
                            if let response = try? await RequestHandler.getIPCityData(IP: server.IPv4, locale: Locale.preferredLanguages[0]), let currentIPCityData = response.result {
                                try? storage.setObject(currentIPCityData, forKey: server.IPv4)
                                if let latitude = currentIPCityData.location.latitude, let longitude = currentIPCityData.location.longitude {
                                    serverCoordinates.append(ServerCoordinate(name: server.name,latitude: latitude, longitude: longitude))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
