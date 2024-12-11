//
//  ServiceDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/10/24.
//

import SwiftUI

struct ServiceDetailView: View {
    let service: ServiceData
    
    @State private var isShowEditServiceSheet: Bool = false
    
    var body: some View {
        Form {
            NMUI.PieceOfInfo(systemImage: "bookmark", name: "Name", content: Text("\(service.name)"))
            NMUI.PieceOfInfo(systemImage: "network", name: "Type", content: Text("\(service.type.title)"))
            NMUI.PieceOfInfo(systemImage: "scope", name: "Target", content: Text("\(service.target)"))
            NMUI.PieceOfInfo(systemImage: "clock", name: "Interval", content: Text("\(service.interval)s"))
        }
        .formStyle(.grouped)
        .navigationTitle(nameCanBeUntitled(service.name))
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    isShowEditServiceSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowEditServiceSheet, content: {
            EditServiceView(service: service)
        })
    }
}
