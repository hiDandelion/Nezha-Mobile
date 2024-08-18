//
//  AdvancedCustomizationView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/15/24.
//

import SwiftUI
import PhotosUI
import WidgetKit

struct AdvancedCustomizationView: View {
    @AppStorage("NMBackgroundPhotoData", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var backgroundPhotoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @Binding var backgroundImage: UIImage?
    @AppStorage("NMThemeCustomizationEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeCustomizationEnabled: Bool = false
    @AppStorage("NMThemePrimaryColorLight", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themePrimaryColorLight: Color = .black
    @AppStorage("NMThemeSecondaryColorLight", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeSecondaryColorLight: Color = Color(red: 1, green: 240/255, blue: 243/255)
    @AppStorage("NMThemeTintColorLight", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeTintColorLight: Color = Color(red: 135/255, green: 14/255, blue: 78/255)
    @AppStorage("NMThemeBackgroundColorLight", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeBackgroundColorLight: Color = Color(red: 1, green: 247/255, blue: 248/255)
    @AppStorage("NMThemePrimaryColorDark", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themePrimaryColorDark: Color = .white
    @AppStorage("NMThemeSecondaryColorDark", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeSecondaryColorDark: Color = Color(red: 33/255, green: 25/255, blue: 28/255)
    @AppStorage("NMThemeTintColorDark", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeTintColorDark: Color = Color(red: 135/255, green: 14/255, blue: 78/255)
    @AppStorage("NMThemeBackgroundColorDark", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var themeBackgroundColorDark: Color = .black
    @AppStorage("NMWidgetCustomizationEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetCustomizationEnabled: Bool = false
    @AppStorage("NMWidgetBackgroundColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetBackgroundColor: Color = .blue
    @AppStorage("NMWidgetTextColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetTextColor: Color = .white
    @State var isShowWidgetsSuccessfullyRefreshedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Text("Select Custom Background")
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                backgroundPhotoData = data
                                backgroundImage = UIImage(data: data)
                            }
                        }
                    }
                    
                    if backgroundImage != nil {
                        Button("Delete Custom Background") {
                            backgroundPhotoData = nil
                            backgroundImage = nil
                        }
                    }
                } header: {
                    Text("Background Customization")
                } footer: {
                    Text("These settings will overwrite theme configurations and custom theme configurations.")
                }
                
                Section {
                    Toggle("Enable Theme Customization", isOn: $themeCustomizationEnabled)
                    if themeCustomizationEnabled {
                        ColorPicker("Primary Color Light Mode", selection: $themePrimaryColorLight)
                        ColorPicker("Secondary Color Light Mode", selection: $themeSecondaryColorLight)
                        ColorPicker("Background Color Light Mode", selection: $themeBackgroundColorLight)
                        ColorPicker("Tint Color Light Mode", selection: $themeTintColorLight)
                        ColorPicker("Primary Color Dark Mode", selection: $themePrimaryColorDark)
                        ColorPicker("Secondary Color Dark Mode", selection: $themeSecondaryColorDark)
                        ColorPicker("Background Color Dark Mode", selection: $themeBackgroundColorDark)
                        ColorPicker("Tint Color Dark Mode", selection: $themeTintColorDark)
                    }
                } header: {
                    Text("Theme Customization")
                } footer: {
                    Text("These settings will overwrite theme configurations.")
                }
                
                Section {
                    Toggle("Enable Widget Customization", isOn: $widgetCustomizationEnabled)
                    if widgetCustomizationEnabled {
                        ColorPicker("Background Color", selection: $selectedWidgetBackgroundColor)
                        ColorPicker("Text Color", selection: $selectedWidgetTextColor)
                    }
                    Button("Refresh Widgets") {
                        WidgetCenter.shared.reloadAllTimelines()
                        isShowWidgetsSuccessfullyRefreshedAlert = true
                    }
                    .alert("Successfuly Refreshed", isPresented: $isShowWidgetsSuccessfullyRefreshedAlert) {
                        Button("OK", role: .cancel) {
                            isShowWidgetsSuccessfullyRefreshedAlert = false
                        }
                    }
                } header: {
                    Text("Widget Customization")
                } footer: {
                    Text("These settings will overwrite widget configurations and apply to all widgets.")
                }
            }
            .navigationTitle("Advanced Customization")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
