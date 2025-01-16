//
//  getOSLogo.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import SwiftUI

extension NMUI {
    static func getOSLogo(OSName: String) -> some View {
        Group {
            if OSName.contains("debian") {
                Image("DebianLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if OSName.contains("ubuntu") {
                Image("UbuntuLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if OSName.contains("Windows") {
                Image("WindowsLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if OSName.contains("darwin") {
                Image("macOSLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if OSName.contains("iOS") {
                Image("iOSLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
        }
    }
}
