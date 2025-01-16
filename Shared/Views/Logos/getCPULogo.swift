//
//  getCPULogo.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import SwiftUI

extension NMUI {
    static func getCPULogo(CPUName: String) -> some View {
        Group {
            if CPUName.contains("AMD") {
                Image("AMDLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if CPUName.contains("Intel") {
                Image("IntelLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if CPUName.contains("Neoverse") {
                Image("ARMLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            if CPUName.contains("Apple") {
                Image("AppleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
        }
    }
}
