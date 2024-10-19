//
//  ChangeThemeView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/6/24.
//

import SwiftUI

struct ChangeThemeView: View {
    @Environment(\.colorScheme) private var scheme
    @AppStorage("NMTheme", store: NMCore.userDefaults) private var theme: NMTheme = .blue
    @Binding var isShowingChangeThemeSheet: Bool
    @Namespace private var animation

    var body: some View {
        let safeArea = self.getSafeAreaInsets()
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            isShowingChangeThemeSheet = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .padding(10)
                            .foregroundStyle(.primary)
                            .background(.primary.opacity(0.06))
                            .clipShape(Circle())
                            .padding()
                            .hoverEffect(.lift)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            
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
                        Button {
                            self.theme = theme
                        } label: {
                            Text(theme.localizedString())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
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
                        }
                        .buttonStyle(.plain)
                        .hoverEffect(.lift)
                    }
                }
                .padding(3)
                .background(.primary.opacity(0.06), in: .capsule)
                .padding(.top, 20)
                .padding(.horizontal, 10)
                .frame(maxWidth: 500)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .background(Color.changeThemeCardBackground)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .padding(.top, safeArea.top == .zero ? 15 : 0)
        .padding(.bottom, safeArea.bottom == .zero ? 15 : 0)
    }
}
