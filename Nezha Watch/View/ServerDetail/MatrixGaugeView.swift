//
//  MatrixGaugeView.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/26/24.
//

import SwiftUI

struct MatrixGaugeView: View {
    let title: String
    let systemName: String
    let percent: Double
    let tintColor: Color
    
    var body: some View {
            Gauge(value: percent, in: 0...100) {
                Text(title)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
            }
            .gaugeStyle(MatrixGaugeStyle(title: title, systemName: systemName, color: tintColor))
    }
}

struct MatrixGaugeStyle: GaugeStyle {
    let title: String
    let systemName: String
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Circle()
                .trim(from: 0, to: CGFloat(configuration.value))
                .rotation(.degrees(-90))
                .stroke(color, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .overlay {
                    ZStack {
                        Circle()
                            .stroke(.quaternary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        VStack(spacing: 5) {
                            VStack {
                                Image(systemName: systemName)
                                    .font(.title2)
                                Text(title)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text("\(configuration.value * 100, specifier: "%.0f")%")
                                .font(.system(.title2, design: .rounded))
                        }
                    }
                }
        }
    }
}
