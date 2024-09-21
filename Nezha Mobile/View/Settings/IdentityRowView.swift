//
//  IdentityRowView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import NezhaMobileData

struct IdentityRowView: View {
    let name: String
    let username: String
    let identityAuthenticationMethod: IdentityAuthenticationMethod
    let privateKeyType: PrivateKeyType?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name != "" ? name : String(localized: "Untitled"))
                HStack {
                    HStack {
                        Image(systemName: "person.circle")
                        Text(username)
                    }
                    
                    HStack {
                        Image(systemName: "key")
                        Text(identityAuthenticationMethod.rawValue)
                    }
                    
                    if let privateKeyType {
                        HStack {
                            Image(systemName: "key.viewfinder")
                            Text(privateKeyType.rawValue)
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
