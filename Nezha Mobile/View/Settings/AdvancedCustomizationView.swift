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
    @Environment(ThemeStore.self) var themeStore
    @AppStorage("NMBackgroundPhotoData", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var backgroundPhotoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State var backgroundImage: UIImage?
    @AppStorage("NMWidgetCustomizationEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetCustomizationEnabled: Bool = false
    @AppStorage("NMWidgetBackgroundColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetBackgroundColor: Color = .blue
    @AppStorage("NMWidgetTextColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetTextColor: Color = .white
    @State var isShowWidgetsSuccessfullyRefreshedAlert: Bool = false
    
    var body: some View {
        Form {
            Section {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Select Custom Background")
                }
                .onChange(of: selectedPhoto) {
                    Task {
                        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
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
            .onAppear {
                // Set background
                let backgroundPhotoData = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")?.data(forKey: "NMBackgroundPhotoData")
                if let backgroundPhotoData {
                    backgroundImage = UIImage(data: backgroundPhotoData)
                }
            }
            
            Section {
                Toggle("Enable Theme Customization", isOn: Bindable(themeStore).themeCustomizationEnabled)
                if themeStore.themeCustomizationEnabled {
                    ColorPicker("Primary Color Light Mode", selection: Bindable(themeStore).themePrimaryColorLight)
                    ColorPicker("Secondary Color Light Mode", selection: Bindable(themeStore).themeSecondaryColorLight)
                    ColorPicker("Background Color Light Mode", selection: Bindable(themeStore).themeBackgroundColorLight)
                    ColorPicker("Tint Color Light Mode", selection: Bindable(themeStore).themeTintColorLight)
                    ColorPicker("Primary Color Dark Mode", selection: Bindable(themeStore).themePrimaryColorDark)
                    ColorPicker("Secondary Color Dark Mode", selection: Bindable(themeStore).themeSecondaryColorDark)
                    ColorPicker("Background Color Dark Mode", selection: Bindable(themeStore).themeBackgroundColorDark)
                    ColorPicker("Tint Color Dark Mode", selection: Bindable(themeStore).themeTintColorDark)
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
