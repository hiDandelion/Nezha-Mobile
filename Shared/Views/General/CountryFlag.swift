//
//  CountryFlag.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/26/25.
//

import SwiftUI

struct CountryFlag: View {
    let countryCode: String
    
    var body: some View {
        if countryCode.uppercased() == "TW" {
            Text("🇹🇼")
        }
        else if countryCode.uppercased() != "" {
            Text(countryFlagEmoji(countryCode: countryCode))
        }
        else {
            Text("🏴‍☠️")
        }
    }
}
