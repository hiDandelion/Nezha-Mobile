//
//  DDNSDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import SwiftUI

struct DDNSDetailView: View {
    @Environment(NMState.self) private var state
    let ddnsID: Int64
    var ddns: DDNSData? {
        state.ddnsProfiles.first(where: { $0.ddnsID == ddnsID })
    }

    @State private var isShowEditDDNSSheet: Bool = false

    var body: some View {
        if let ddns {
            Form {
                Section {
                    NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(ddns.name)"))
                    NMUI.PieceOfInfo(systemImage: "cloud", name: "Provider", content: Text("\(ddns.provider)"))
                }

                Section("Domains") {
                    if !ddns.domains.isEmpty {
                        ForEach(ddns.domains, id: \.self) { domain in
                            Text(domain)
                        }
                    }
                    else {
                        Text("No Domains")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("IP Settings") {
                    NMUI.PieceOfInfo(systemImage: "4.circle", name: "IPv4", content: Text(ddns.enableIPv4 ? "Enabled" : "Disabled"))
                    NMUI.PieceOfInfo(systemImage: "6.circle", name: "IPv6", content: Text(ddns.enableIPv6 ? "Enabled" : "Disabled"))
                    NMUI.PieceOfInfo(systemImage: "arrow.clockwise", name: "Max Retries", content: Text("\(ddns.maxRetries)"))
                }
            }
            .formStyle(.grouped)
            .navigationTitle(nameCanBeUntitled(ddns.name))
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowEditDDNSSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowEditDDNSSheet, content: {
                EditDDNSView(ddns: ddns)
            })
        }
    }
}
