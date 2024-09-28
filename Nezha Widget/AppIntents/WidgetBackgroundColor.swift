//
//  WidgetBackgroundColor.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/27/24.
//

import AppIntents

enum WidgetBackgroundColor: String, Codable, Sendable {
    case blue
    case green
    case orange
    case black
}

extension WidgetBackgroundColor: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: LocalizedStringResource("Color"))
    }
    
    static let caseDisplayRepresentations: [WidgetBackgroundColor : DisplayRepresentation] = [
        .blue: DisplayRepresentation(title: "Ocean"),
        .green: DisplayRepresentation(title: "Leaf"),
        .orange: DisplayRepresentation(title: "Maple"),
        .black: DisplayRepresentation(title: "Obsidian"),
    ]
}
