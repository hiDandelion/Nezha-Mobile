//
//  AdvancedThemeCustomizationView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/15/24.
//

import SwiftUI
import PhotosUI
import WidgetKit

struct AdvancedThemeCustomizationView: View {
    @AppStorage("NMBackgroundPhotoData", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var backgroundPhotoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @Binding var backgroundImage: UIImage?
    @AppStorage("NMWidgetCustomizationEnabled", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var widgetCustomizationEnabled: Bool = false
    @AppStorage("NMWidgetBackgroundColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetBackgroundColor: Color = .blue
    @AppStorage("NMWidgetTextColor", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var selectedWidgetTextColor: Color = .white
    @State var isShowWidgetsSuccessfullyRefreshedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Background Customization") {
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
                }
                
                Section {
                    Toggle("Enable Widget Customization", isOn: $widgetCustomizationEnabled)
                    if widgetCustomizationEnabled {
                        ColorPicker("Background Color", selection: $selectedWidgetBackgroundColor)
                        ColorPicker("Text Color", selection: $selectedWidgetTextColor)
                    }
                    Button("Refresh widgets") {
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
