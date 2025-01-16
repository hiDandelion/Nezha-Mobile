//
//  NMTheme.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/19/24.
//

import SwiftUI
import ColorfulX

@Observable
class NMTheme {
    static let NMThemePrimaryColorLight = "NM1.13ThemePrimaryColorLight"
    static let NMThemeSecondaryColorLight = "NM1.13ThemeSecondaryColorLight"
    static let NMThemeActiveColorLight = "NM1.13ThemeActiveColorLight"
    static let NMThemeTintColorLight = "NM1.13ThemeTintColorLight"
    static let NMThemePrimaryColorDark = "NM1.13ThemePrimaryColorDark"
    static let NMThemeSecondaryColorDark = "NM1.13ThemeSecondaryColorDark"
    static let NMThemeActiveColorDark = "NM1.13ThemeActiveColorDark"
    static let NMThemeTintColorDark = "NM1.13ThemeTintColorDark"
    
    static let NMThemeBackgroundColorLight = "NM1.13ThemeBackgroundColorLight"
    static let NMThemeBackgroundColorDark = "NM1.13ThemeBackgroundColorDark"
    
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
    
    var themeBackgroundColorLight: ColorfulX.ColorfulPreset {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorLight.rawValue, forKey: NMTheme.NMThemeBackgroundColorLight)
        }
    }
    var themeBackgroundColorDark: ColorfulX.ColorfulPreset {
        didSet {
            NMCore.userDefaults.set(themeBackgroundColorDark.rawValue, forKey: NMTheme.NMThemeBackgroundColorDark)
        }
    }
    
    init() {
        if
            let themePrimaryColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemePrimaryColorLight),
            let themeSecondaryColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeSecondaryColorLight),
            let themeActiveColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeActiveColorLight),
            let themeTintColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeTintColorLight),
            let themePrimaryColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemePrimaryColorDark),
            let themeSecondaryColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeSecondaryColorDark),
            let themeActiveColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeActiveColorDark),
            let themeTintColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeTintColorDark),
            let themeBackgroundColorLightString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeBackgroundColorLight),
            let themeBackgroundColorDarkString = NMCore.userDefaults.string(forKey: NMTheme.NMThemeBackgroundColorDark)
        {
            themePrimaryColorLight = Color(base64EncodedString: themePrimaryColorLightString) ?? Color.black
            themeSecondaryColorLight = Color(base64EncodedString: themeSecondaryColorLightString) ?? Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5)
            themeActiveColorLight = Color(base64EncodedString: themeActiveColorLightString) ?? Color.white
            themeTintColorLight = Color(base64EncodedString: themeTintColorLightString) ?? Color.blue
            themePrimaryColorDark = Color(base64EncodedString: themePrimaryColorDarkString) ?? Color.white
            themeSecondaryColorDark = Color(base64EncodedString: themeSecondaryColorDarkString) ?? Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.5)
            themeActiveColorDark = Color(base64EncodedString: themeActiveColorDarkString) ?? Color.white
            themeTintColorDark = Color(base64EncodedString: themeTintColorDarkString) ?? Color.blue
            
            themeBackgroundColorLight = ColorfulPreset(rawValue: themeBackgroundColorLightString) ?? ColorfulPreset.ocean
            themeBackgroundColorDark = ColorfulPreset(rawValue: themeBackgroundColorDarkString) ?? ColorfulPreset.neon
        }
        else {
            themePrimaryColorLight = Color.black
            themeSecondaryColorLight = Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5)
            themeActiveColorLight = Color.white
            themeTintColorLight = Color.blue
            themePrimaryColorDark = Color.white
            themeSecondaryColorDark = Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.5)
            themeActiveColorDark = Color.white
            themeTintColorDark = Color.blue
            
            themeBackgroundColorLight = ColorfulPreset.ocean
            themeBackgroundColorDark = ColorfulPreset.neon
            
            NMCore.userDefaults.set(themePrimaryColorLight.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorLight)
            NMCore.userDefaults.set(themeSecondaryColorLight.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorLight)
            NMCore.userDefaults.set(themeActiveColorLight.base64EncodedString, forKey: NMTheme.NMThemeActiveColorLight)
            NMCore.userDefaults.set(themeTintColorLight.base64EncodedString, forKey: NMTheme.NMThemeTintColorLight)
            NMCore.userDefaults.set(themePrimaryColorDark.base64EncodedString, forKey: NMTheme.NMThemePrimaryColorDark)
            NMCore.userDefaults.set(themeSecondaryColorDark.base64EncodedString, forKey: NMTheme.NMThemeSecondaryColorDark)
            NMCore.userDefaults.set(themeActiveColorDark.base64EncodedString, forKey: NMTheme.NMThemeActiveColorDark)
            NMCore.userDefaults.set(themeTintColorDark.base64EncodedString, forKey: NMTheme.NMThemeTintColorDark)
            
            NMCore.userDefaults.set(themeBackgroundColorLight.rawValue, forKey: NMTheme.NMThemeBackgroundColorLight)
            NMCore.userDefaults.set(themeBackgroundColorDark.rawValue, forKey: NMTheme.NMThemeBackgroundColorDark)
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
    
    func themeBackgroundColor(scheme: ColorScheme) -> ColorfulX.ColorfulPreset {
        return scheme == .light ? themeBackgroundColorLight : themeBackgroundColorDark
    }
}
