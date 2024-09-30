//
//  LogoViews.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/29/24.
//

import SwiftUI

func OSImage(OSName: String) -> some View {
    Group {
        if OSName.contains("debian") {
            Image("DebianLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if OSName.contains("ubuntu") {
            Image("UbuntuLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if OSName.contains("Windows") {
            Image("WindowsLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if OSName.contains("darwin") {
            Image("macOSLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if OSName.contains("iOS") {
            Image("iOSLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
    }
}

func CPUImage(CPUName: String) -> some View {
    Group {
        if CPUName.contains("AMD") {
            Image("AMDLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if CPUName.contains("Intel") {
            Image("IntelLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if CPUName.contains("Neoverse") {
            Image("ARMLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        if CPUName.contains("Apple") {
            Image("AppleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
    }
}

func GPUImage(GPUName: String) -> some View {
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
