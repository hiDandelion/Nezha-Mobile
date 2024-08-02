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

/// Time Related
func formatTimeInterval(_ interval: Int) -> String {
    let seconds = interval / 1000
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24
    let months = days / 30
    let years = months / 12

    if years > 0 {
        return "\(years)y \(months % 12)m \(days % 30)d"
    } else if months > 0 {
        return "\(months)m \(days % 30)d"
    } else if days > 0 {
        return "\(days)d \(hours % 24)h"
    } else if hours > 0 {
        return "\(hours)h \(minutes % 60)m"
    } else if minutes > 0 {
        return "\(minutes)m \(seconds % 60)s"
    } else {
        return "\(seconds)s"
    }
}

/// Style Related
func backgroundGradient(color: String) -> LinearGradient {
    switch color {
    case "blue":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    case "yellow":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 176/255, blue: 59/255), Color(red: 212/255, green: 20/255, blue: 90/255)]), startPoint: .top, endPoint: .bottom)
    case "green":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 252/255, green: 238/255, blue: 33/255), Color(red: 0/255, green: 146/255, blue: 69/255)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    }
}

/// Offset Preference Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
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

/// Orient Extension
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
