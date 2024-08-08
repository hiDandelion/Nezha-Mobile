//
//  ChangeThemeView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/6/24.
//

import SwiftUI

enum NMTheme: String, CaseIterable {
    case blue = "Ocean"
    case green = "Leaf"
    case yellow = "Maple"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ChangeThemeView: View {
    @Environment(\.colorScheme) private var scheme
    @AppStorage("NMTheme", store: UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile")) private var theme: NMTheme = .blue
    @Namespace private var animation

    var body: some View {
        let safeArea = self.getSafeAreaInsets()
        VStack(spacing: 15) {
            Circle()
                .fill(backgroundGradient(color: theme, scheme: scheme))
                .frame(width: 150, height: 150)
            
            Text("Choose Style")
                .font(.title2.bold())
                .padding(.top, 25)
            
            Text("Customize your interface")
                .multilineTextAlignment(.center)
            
            /// Segmented Picker
            HStack(spacing: 0) {
                ForEach(NMTheme.allCases, id: \.rawValue) { theme in
                    Text(theme.localizedString())
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background {
                            ZStack {
                                if self.theme == theme {
                                    Capsule()
                                        .fill(Color.changeThemeCardBackground)
                                        .matchedGeometryEffect(id: "ACTIVETHEMETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: self.theme)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            self.theme = theme
                        }
                }
            }
            .padding(3)
            .background(.primary.opacity(0.06), in: .capsule)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: safeArea.bottom == .zero ? 395 : 410)
        .background(Color.changeThemeCardBackground)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .padding(.bottom, safeArea.bottom == .zero ? 15 : 0)
    }
}
