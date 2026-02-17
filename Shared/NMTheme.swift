//
//  NMTheme.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/19/24.
//

import SwiftUI

@Observable
class NMTheme {
    static let NMThemePrimaryColorLight = "NM1.13ThemePrimaryColorLight"
    static let NMThemeSecondaryColorLight = "NM1.13ThemeSecondaryColorLight"
    static let NMThemeBackgroundColorLight = "NM1.13ThemeBackgroundColorLight"
    static let NMThemeActiveColorLight = "NM1.13ThemeActiveColorLight"
    static let NMThemeTintColorLight = "NM1.13ThemeTintColorLight"
    static let NMThemePrimaryColorDark = "NM1.13ThemePrimaryColorDark"
    static let NMThemeSecondaryColorDark = "NM1.13ThemeSecondaryColorDark"
    static let NMThemeBackgroundColorDark = "NM1.13ThemeBackgroundColorDark"
    static let NMThemeActiveColorDark = "NM1.13ThemeActiveColorDark"
    static let NMThemeTintColorDark = "NM1.13ThemeTintColorDark"
    
    static let defaultThemePrimaryColorLight = Color.black
    static let defaultThemeSecondaryColorLight = Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5)
    static let defaultThemeBackgroundColorLight = Color(red: 140/255, green: 196/255, blue: 246/255)
    static let defaultThemeActiveColorLight = Color.white
    static let defaultThemeTintColorLight = Color.blue
    static let defaultThemePrimaryColorDark = Color.white
    static let defaultThemeSecondaryColorDark = Color(red: 30/255, green: 30/255, blue: 30/255, opacity: 0.5)
    static let defaultThemeBackgroundColorDark = Color.black
    static let defaultThemeActiveColorDark = Color.white
    static let defaultThemeTintColorDark = Color.blue
    
    var themePrimaryColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themePrimaryColorLight.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorLight)
        }
    }
    var themeSecondaryColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeSecondaryColorLight.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorLight)
        }
    }
    var themeBackgroundColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorLight.rawValue, forKey: NMTheme.NMThemeBackgroundColorLight)
        }
    }
    var themeActiveColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeActiveColorLight.base64EncodedString, forKey: NMTheme.NMThemeActiveColorLight)
        }
    }
    var themeTintColorLight: Color {
        didSet {
            NMCore.userDefaults.set(themeTintColorLight.base64EncodedString, forKey: NMTheme.NMThemeTintColorLight)
        }
    }
    var themePrimaryColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themePrimaryColorDark.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorDark)
        }
    }
    var themeSecondaryColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeSecondaryColorDark.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorDark)
        }
    }
    var themeBackgroundColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorDark.rawValue, forKey: NMTheme.NMThemeBackgroundColorDark)
        }
    }
    var themeActiveColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeActiveColorDark.base64EncodedString, forKey: NMTheme.NMThemeActiveColorDark)
        }
    }
    var themeTintColorDark: Color {
        didSet {
            NMCore.userDefaults.set(themeTintColorDark.base64EncodedString, forKey: NMTheme.NMThemeTintColorDark)
        }
    }
    
    init() {
        if
            let themePrimaryColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemePrimaryColorLight),
            let themeSecondaryColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeSecondaryColorLight),
            let themeBackgroundColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeBackgroundColorLight),
            let themeActiveColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeActiveColorLight),
            let themeTintColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeTintColorLight),
            let themePrimaryColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemePrimaryColorDark),
            let themeSecondaryColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeSecondaryColorDark),
            let themeBackgroundColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeBackgroundColorDark),
            let themeActiveColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeActiveColorDark),
            let themeTintColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeTintColorDark)
        {
            themePrimaryColorLight = Color(base64EncodedString: themePrimaryColorLightString) ?? NMTheme.defaultThemePrimaryColorLight
            themeSecondaryColorLight = Color(base64EncodedString: themeSecondaryColorLightString) ?? NMTheme.defaultThemeSecondaryColorLight
            themeBackgroundColorLight = Color(base64EncodedString: themeBackgroundColorLightString) ?? NMTheme.defaultThemeBackgroundColorLight
            themeActiveColorLight = Color(base64EncodedString: themeActiveColorLightString) ?? NMTheme.defaultThemeActiveColorLight
            themeTintColorLight = Color(base64EncodedString: themeTintColorLightString) ?? NMTheme.defaultThemeTintColorLight
            themePrimaryColorDark = Color(base64EncodedString: themePrimaryColorDarkString) ?? NMTheme.defaultThemePrimaryColorDark
            themeSecondaryColorDark = Color(base64EncodedString: themeSecondaryColorDarkString) ?? NMTheme.defaultThemeSecondaryColorDark
            themeBackgroundColorDark = Color(base64EncodedString: themeBackgroundColorDarkString) ?? NMTheme.defaultThemeBackgroundColorDark
            themeActiveColorDark = Color(base64EncodedString: themeActiveColorDarkString) ?? NMTheme.defaultThemeActiveColorDark
            themeTintColorDark = Color(base64EncodedString: themeTintColorDarkString) ?? NMTheme.defaultThemeTintColorDark
        }
        else {
            themePrimaryColorLight = NMTheme.defaultThemePrimaryColorLight
            themeSecondaryColorLight = NMTheme.defaultThemeSecondaryColorLight
            themeBackgroundColorLight = NMTheme.defaultThemeBackgroundColorLight
            themeActiveColorLight = NMTheme.defaultThemeActiveColorLight
            themeTintColorLight = NMTheme.defaultThemeTintColorLight
            themePrimaryColorDark = NMTheme.defaultThemePrimaryColorDark
            themeSecondaryColorDark = NMTheme.defaultThemeSecondaryColorDark
            themeBackgroundColorDark = NMTheme.defaultThemeBackgroundColorDark
            themeActiveColorDark = NMTheme.defaultThemeActiveColorDark
            themeTintColorDark = NMTheme.defaultThemeTintColorDark
            
            NMCore.userDefaults.set(themePrimaryColorLight.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorLight)
            NMCore.userDefaults.set(themeSecondaryColorLight.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorLight)
            NMCore.userDefaults.set(themeBackgroundColorLight.base64EncodedString, forKey: NMTheme.NMThemeBackgroundColorLight)
            NMCore.userDefaults.set(themeActiveColorLight.base64EncodedString, forKey: NMTheme.NMThemeActiveColorLight)
            NMCore.userDefaults.set(themeTintColorLight.base64EncodedString, forKey: NMTheme.NMThemeTintColorLight)
            NMCore.userDefaults.set(themePrimaryColorDark.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorDark)
            NMCore.userDefaults.set(themeSecondaryColorDark.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorDark)
            NMCore.userDefaults.set(themeBackgroundColorDark.base64EncodedString, forKey: NMTheme.NMThemeBackgroundColorDark)
            NMCore.userDefaults.set(themeActiveColorDark.base64EncodedString, forKey: NMTheme.NMThemeActiveColorDark)
            NMCore.userDefaults.set(themeTintColorDark.base64EncodedString, forKey: NMTheme.NMThemeTintColorDark)
        }
    }
    
    func themePrimaryColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themePrimaryColorLight : themePrimaryColorDark
    }
    
    func themeSecondaryColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeSecondaryColorLight : themeSecondaryColorDark
    }
    
    func themeActiveColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeActiveColorLight : themeActiveColorDark
    }
    
    func themeTintColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeTintColorLight : themeTintColorDark
    }
    
    func themeBackgroundColor(scheme: ColorScheme) -> Color {
        return scheme == .light ? themeBackgroundColorLight : themeBackgroundColorDark
    }
}
