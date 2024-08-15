//
//  ViewUtilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/2/24.
//

import SwiftUI

/// Style Related
func themeColor(theme: NMTheme) -> Color {
    switch (theme) {
    case .blue:
        return Color.blue
    case .green:
        return Color.green
    case .orange:
        return Color.orange
    }
}

func backgroundGradient(color: NMTheme, scheme: ColorScheme) -> LinearGradient {
    switch (color, scheme) {
    case (.blue, .light):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    case (.blue, .dark):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 36/255, green: 134/255, blue: 194/255), Color(red: 24/255, green: 43/255, blue: 58/255)]), startPoint: .top, endPoint: .bottom)
    case (.green, .light):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 252/255, green: 238/255, blue: 33/255), Color(red: 0/255, green: 146/255, blue: 69/255)]), startPoint: .top, endPoint: .bottom)
    case (.green, .dark):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 22/255, green: 109/255, blue: 59/255), Color(red: 12/255, green: 35/255, blue: 17/255)]), startPoint: .top, endPoint: .bottom)
    case (.orange, .light):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 176/255, blue: 59/255), Color(red: 212/255, green: 20/255, blue: 90/255)]), startPoint: .top, endPoint: .bottom)
    case (.orange, .dark):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 204/255, green: 80/255, blue: 56/255), Color(red: 100/255, green: 19/255, blue: 16/255)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    }
}

/// Offset Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// offsetChange
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
    
    func getSafeAreaInsets() -> UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

/// Orientation
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
