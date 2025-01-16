//
//  ThemeSettingsView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/15/24.
//

import SwiftUI
import PhotosUI
#if os(iOS)
import WidgetKit
#endif
import ColorfulX

struct ThemeSettingsView: View {
    @Environment(NMTheme.self) var theme
    @AppStorage("NMBackgroundPhotoData", store: NMCore.userDefaults) private var backgroundPhotoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
#if os(iOS) || os(visionOS)
    @State var backgroundImage: UIImage?
#endif
#if os(macOS)
    @State var backgroundImage: NSImage?
#endif
    @AppStorage("NMWidgetCustomizationEnabled", store: NMCore.userDefaults) private var widgetCustomizationEnabled: Bool = false
    @AppStorage("NMWidgetBackgroundColor", store: NMCore.userDefaults) private var selectedWidgetBackgroundColor: Color = .blue
    @AppStorage("NMWidgetTextColor", store: NMCore.userDefaults) private var selectedWidgetTextColor: Color = .white
    @State var isShowWidgetsSuccessfullyRefreshedAlert: Bool = false
    
    var body: some View {
        Form {
            Section {
                Picker("Background Color Set Light", selection: Bindable(theme).themeBackgroundColorLight) {
                    ForEach(ColorfulX.ColorfulPreset.allCases, id: \.self) {
                        Text($0.hint)
                            .tag($0)
                    }
                }
                Picker("Background Color Set Dark", selection: Bindable(theme).themeBackgroundColorDark) {
                    ForEach(ColorfulX.ColorfulPreset.allCases, id: \.self) {
                        Text($0.hint)
                            .tag($0)
                    }
                }
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Select Custom Background")
                }
                .onChange(of: selectedPhoto) {
                    Task {
                        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                            backgroundPhotoData = data
#if os(iOS) || os(visionOS)
                            backgroundImage = UIImage(data: data)
#endif
#if os(macOS)
                            backgroundImage = NSImage(data: data)
#endif
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
            }
            .onAppear {
                // Set background
                let backgroundPhotoData = NMCore.userDefaults.data(forKey: "NMBackgroundPhotoData")
                if let backgroundPhotoData {
#if os(iOS) || os(visionOS)
                    backgroundImage = UIImage(data: backgroundPhotoData)
#endif
#if os(macOS)
                    backgroundImage = NSImage(data: backgroundPhotoData)
#endif
                }
            }
            
            Section {
                ColorPicker("Primary Color Light Mode", selection: Bindable(theme).themePrimaryColorLight)
                ColorPicker("Secondary Color Light Mode", selection: Bindable(theme).themeSecondaryColorLight)
                ColorPicker("Active Color Light Mode", selection: Bindable(theme).themeActiveColorLight)
                ColorPicker("Tint Color Light Mode", selection: Bindable(theme).themeTintColorLight)
                ColorPicker("Primary Color Dark Mode", selection: Bindable(theme).themePrimaryColorDark)
                ColorPicker("Secondary Color Dark Mode", selection: Bindable(theme).themeSecondaryColorDark)
                ColorPicker("Active Color Dark Mode", selection: Bindable(theme).themeActiveColorDark)
                ColorPicker("Tint Color Dark Mode", selection: Bindable(theme).themeTintColorDark)
            } header: {
                Text("Theme Customization")
            }
            
#if os(iOS)
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
#endif
        }
        .navigationTitle("Theme Settings")
#if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#if os(macOS)
        .padding()
        .frame(width: 600, height: 600)
        .tabItem {
            Label("Theme", systemImage: "paintbrush")
        }
#endif
    }
}
