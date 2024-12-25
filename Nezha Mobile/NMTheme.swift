//
//  NMTheme.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/19/24.
//

import SwiftUI

@Observable
class NMTheme {
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
            themeSecondaryColorLight = Color(base64EncodedString: themeSecondaryColorLightString) ?? Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5)
            themeActiveColorLight = Color(base64EncodedString: themeActiveColorLightString) ?? Color.white
            themeTintColorLight = Color(base64EncodedString: themeTintColorLightString) ?? Color.blue
            themeBackgroundColorLight = Color(base64EncodedString: themeBackgroundColorLightString) ?? Color(red: 140/255, green: 196/255, blue: 246/255)
            themePrimaryColorDark = Color(base64EncodedString: themePrimaryColorDarkString) ?? Color.white
            themeSecondaryColorDark = Color(base64EncodedString: themeSecondaryColorDarkString) ?? Color(red: 28/255, green: 28/255, blue: 28/255)
            themeActiveColorDark = Color(base64EncodedString: themeActiveColorDarkString) ?? Color.white
            themeTintColorDark = Color(base64EncodedString: themeTintColorDarkString) ?? Color.blue
            themeBackgroundColorDark = Color(base64EncodedString: themeBackgroundColorDarkString) ?? Color.black
        }
        else {
            themePrimaryColorLight = Color.black
            themeSecondaryColorLight = Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5)
            themeActiveColorLight = Color.white
            themeTintColorLight = Color.blue
            themeBackgroundColorLight = Color(red: 140/255, green: 196/255, blue: 246/255)
            themePrimaryColorDark = Color.white
            themeSecondaryColorDark = Color(red: 28/255, green: 28/255, blue: 28/255)
            themeActiveColorDark = Color.white
            themeTintColorDark = Color.blue
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
