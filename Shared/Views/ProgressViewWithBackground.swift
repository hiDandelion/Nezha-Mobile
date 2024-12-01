//
//  ProgressViewWithBackground.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

import SwiftUI

struct ProgressViewWithBackground: View {
    var body: some View {
        ProgressView()
            .padding(50)
            .background(.thickMaterial)
            .cornerRadius(16)
    }
}
