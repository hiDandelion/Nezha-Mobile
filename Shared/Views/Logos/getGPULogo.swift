//
//  getGPULogo.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 11/19/24.
//

import SwiftUI

extension NMUI {
    static func getGPULogo(GPUName: String) -> some View {
        Group {
            if GPUName.contains("AMD") {
                Image("AMDLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
            }
            if GPUName.contains("Apple") {
                Image("AppleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
            }
        }
    }
}
