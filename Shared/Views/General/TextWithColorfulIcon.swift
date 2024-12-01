//
//  TextWithColorfulIcon.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/28/24.
//

import SwiftUI

struct TextWithColorfulIcon: View {
    let titleKey: LocalizedStringKey
    let systemName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.white)
                .padding(5)
                .background(color)
                .cornerRadius(7)
            Text(titleKey)
        }
    }
}
