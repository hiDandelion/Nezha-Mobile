//
//  ThemeStore.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/19/24.
//

import SwiftUI

enum NMTheme: String, CaseIterable {
    case blue = "Ocean"
    case green = "Leaf"
    case orange = "Maple"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

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
        return LinearGradient(gradient: Gradient(colors: [Color(red: 52/255, green: 95/255, blue: 133/255), Color(red: 24/255, green: 43/255, blue: 58/255)]), startPoint: .top, endPoint: .bottom)
    case (.green, .light):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 252/255, green: 238/255, blue: 33/255), Color(red: 0/255, green: 146/255, blue: 69/255)]), startPoint: .top, endPoint: .bottom)
    case (.green, .dark):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 36/255, green: 71/255, blue: 41/255), Color(red: 12/255, green: 35/255, blue: 17/255)]), startPoint: .top, endPoint: .bottom)
    case (.orange, .light):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 176/255, blue: 59/255), Color(red: 212/255, green: 20/255, blue: 90/255)]), startPoint: .top, endPoint: .bottom)
    case (.orange, .dark):
        return LinearGradient(gradient: Gradient(colors: [Color(red: 136/255, green: 54/255, blue: 40/255), Color(red: 100/255, green: 19/255, blue: 16/255)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    }
}

@Observable
class ThemeStore: ObservableObject {
    var themeCustomizationEnabled: Bool {
        didSet {
            NMCore.userDefaults.set(themeCustomizationEnabled, forKey: "NMThemeCustomizationEnabled")
        }
    }
    var themePrimaryColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themePrimaryColorLight.base64EncodedString, forKey: "NMThemePrimaryColorLight")
        }
    }
    var themeSecondaryColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeSecondaryColorLight.base64EncodedString, forKey: "NMThemeSecondaryColorLight")
        }
    }
    var themeActiveColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeActiveColorLight.base64EncodedString, forKey: "NMThemeActiveColorLight")
        }
    }
    var themeTintColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeTintColorLight.base64EncodedString, forKey: "NMThemeTintColorLight")
        }
    }
    var themeBackgroundColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorLight.base64EncodedString, forKey: "NMThemeBackgroundColorLight")
        }
    }
    var themePrimaryColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themePrimaryColorDark.base64EncodedString, forKey: "NMThemePrimaryColorDark")
        }
    }
    var themeSecondaryColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeSecondaryColorDark.base64EncodedString, forKey: "NMThemeSecondaryColorDark")
        }
    }
    var themeActiveColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeActiveColorDark.base64EncodedString, forKey: "NMThemeActiveColorDark")
        }
    }
    var themeTintColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeTintColorDark.base64EncodedString, forKey: "NMThemeTintColorDark")
        }
    }
    var themeBackgroundColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorDark.base64EncodedString, forKey: "NMThemeBackgroundColorDark")
        }
    }
    
    init() {
        themeCustomizationEnabled = NMCore.userDefaults.bool(forKey: "NMThemeCustomizationEnabled")
        if
            let themePrimaryColorLightString = NMCore.userDefaults.string(forKey: "NMThemePrimaryColorLight"),
            let themeSecondaryColorLightString = NMCore.userDefaults.string(forKey: "NMThemeSecondaryColorLight"),
            let themeActiveColorLightString = NMCore.userDefaults.string(forKey: "NMThemeActiveColorLight"),
            let themeTintColorLightString = NMCore.userDefaults.string(forKey: "NMThemeTintColorLight"),
            let themeBackgroundColorLightString = NMCore.userDefaults.string(forKey: "NMThemeBackgroundColorLight"),
            let themePrimaryColorDarkString = NMCore.userDefaults.string(forKey: "NMThemePrimaryColorDark"),
            let themeSecondaryColorDarkString = NMCore.userDefaults.string(forKey: "NMThemeSecondaryColorDark"),
            let themeActiveColorDarkString = NMCore.userDefaults.string(forKey: "NMThemeActiveColorDark"),
            let themeTintColorDarkString = NMCore.userDefaults.string(forKey: "NMThemeTintColorDark"),
            let themeBackgroundColorDarkString = NMCore.userDefaults.string(forKey: "NMThemeBackgroundColorDark")
        {
            themePrimaryColorLight = Color(base64EncodedString: themePrimaryColorLightString) ?? Color.black
            themeSecondaryColorLight = Color(base64EncodedString: themeSecondaryColorLightString) ?? Color(red: 1, green: 240/255, blue: 243/255)
            themeActiveColorLight = Color(base64EncodedString: themeActiveColorLightString) ?? Color.white
            themeTintColorLight = Color(base64EncodedString: themeTintColorLightString) ?? Color(red: 135/255, green: 14/255, blue: 78/255)
            themeBackgroundColorLight = Color(base64EncodedString: themeBackgroundColorLightString) ?? Color(red: 1, green: 247/255, blue: 248/255)
            themePrimaryColorDark = Color(base64EncodedString: themePrimaryColorDarkString) ?? Color.white
            themeSecondaryColorDark = Color(base64EncodedString: themeSecondaryColorDarkString) ?? Color(red: 33/255, green: 25/255, blue: 28/255)
            themeActiveColorDark = Color(base64EncodedString: themeActiveColorDarkString) ?? Color.white
            themeTintColorDark = Color(base64EncodedString: themeTintColorDarkString) ?? Color(red: 135/255, green: 14/255, blue: 78/255)
            themeBackgroundColorDark = Color(base64EncodedString: themeBackgroundColorDarkString) ?? Color.black
        }
        else {
            themePrimaryColorLight = Color.black
            themeSecondaryColorLight = Color(red: 1, green: 240/255, blue: 243/255)
            themeActiveColorLight = Color.white
            themeTintColorLight = Color(red: 135/255, green: 14/255, blue: 78/255)
            themeBackgroundColorLight = Color(red: 1, green: 247/255, blue: 248/255)
            themePrimaryColorDark = Color.white
            themeSecondaryColorDark = Color(red: 33/255, green: 25/255, blue: 28/255)
            themeActiveColorDark = Color.white
            themeTintColorDark = Color(red: 135/255, green: 14/255, blue: 78/255)
            themeBackgroundColorDark = Color.black
            NMCore.userDefaults.set(themePrimaryColorLight.base64EncodedString, forKey: "NMThemePrimaryColorLight")
            NMCore.userDefaults.set(themeSecondaryColorLight.base64EncodedString, forKey: "NMThemeSecondaryColorLight")
            NMCore.userDefaults.set(themeActiveColorLight.base64EncodedString, forKey: "NMThemeActiveColorLight")
            NMCore.userDefaults.set(themeTintColorLight.base64EncodedString, forKey: "NMThemeTintColorLight")
            NMCore.userDefaults.set(themeBackgroundColorLight.base64EncodedString, forKey: "NMThemeBackgroundColorLight")
            NMCore.userDefaults.set(themePrimaryColorDark.base64EncodedString, forKey: "NMThemePrimaryColorDark")
            NMCore.userDefaults.set(themeSecondaryColorDark.base64EncodedString, forKey: "NMThemeSecondaryColorDark")
            NMCore.userDefaults.set(themeActiveColorDark.base64EncodedString, forKey: "NMThemeActiveColorDark")
            NMCore.userDefaults.set(themeTintColorDark.base64EncodedString, forKey: "NMThemeTintColorDark")
            NMCore.userDefaults.set(themeBackgroundColorDark.base64EncodedString, forKey: "NMThemeBackgroundColorDark")
        }
    }
    
    func themePrimaryColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themePrimaryColorLight : themePrimaryColorDark
    }
    
    func themeSecondaryColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeSecondaryColorLight : themeSecondaryColorDark
    }
    
    func themeBackgroundColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeBackgroundColorLight : themeBackgroundColorDark
    }
    
    func themeActiveColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeActiveColorLight : themeActiveColorDark
    }
    
    func themeTintColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeTintColorLight : themeTintColorDark
    }
}
