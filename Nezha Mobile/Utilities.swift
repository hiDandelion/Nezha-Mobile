//
//  Utilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import SwiftUI

/// Text Related
func formatBytes(_ bytes: Int) -> String {
    return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
}

func getCore(_ str: [String]?) -> String {
    guard let firstStr = str?.first else {
        return "N/A"
    }
    
    let physicalCorePattern = #"(\d|\.)+ Physical"#
    let virtualCorePattern = #"(\d|\.)+ Virtual"#
    
    if let physicalCore = firstStr.range(of: physicalCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return physicalCore.replacingOccurrences(of: "Physical", with: "Core")
    } else if let virtualCore = firstStr.range(of: virtualCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return virtualCore.replacingOccurrences(of: "Virtual", with: "Core")
    } else {
        return "N/A"
    }
}

func countryFlagEmoji(countryCode: String) -> String {
    let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    
    return countryCode
        .uppercased()
        .unicodeScalars
        .map { String(UnicodeScalar(base + $0.value)!) }
        .joined()
}

/// Style Related
func backgroundGradient(color: String) -> LinearGradient {
    switch color {
    case "blue":
        return LinearGradient(gradient: Gradient(colors: [.white, .blue, .black]), startPoint: .top, endPoint: .bottom)
    case "green":
        return LinearGradient(gradient: Gradient(colors: [.white, .green, .black]), startPoint: .top, endPoint: .bottom)
    case "yellow":
        return LinearGradient(gradient: Gradient(colors: [.white, .yellow, .black]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [.white, .blue, .black]), startPoint: .top, endPoint: .bottom)
    }
}

/// Offset Preference Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// offsetChange Extension
extension View {
    @ViewBuilder
    func offsetChange(offset: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: OffsetKey.self, value: geometry.frame(in: .global))
                        .onPreferenceChange(OffsetKey.self) { value in
                            DispatchQueue.main.async {
                                let safeArea = getSafeAreaInsets()
                                let adjustedRect = CGRect(
                                    x: value.minX,
                                    y: value.minY - safeArea.top,
                                    width: value.width,
                                    height: value.height
                                )
                                offset(adjustedRect)
                            }
                        }
                }
            }
    }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}
