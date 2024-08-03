//
//  Utilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import SwiftUI

/// Text Related
func formatBytes(_ bytes: Int) -> String {
    return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
}

func getCore(_ str: [String]?) -> String {
    guard let firstStr = str?.first else {
        return "N/A"
    }
    
    let physicalCorePattern = #"(\d|\.)+ Physical"#
    let virtualCorePattern = #"(\d|\.)+ Virtual"#
    
    if let physicalCore = firstStr.range(of: physicalCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return physicalCore.replacingOccurrences(of: "Physical", with: "Core")
    } else if let virtualCore = firstStr.range(of: virtualCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return virtualCore.replacingOccurrences(of: "Virtual", with: "Core")
    } else {
        return "N/A"
    }
}

func countryFlagEmoji(countryCode: String) -> String {
    let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    
    return countryCode
        .uppercased()
        .unicodeScalars
        .map { String(UnicodeScalar(base + $0.value)!) }
        .joined()
}

extension String {
    func toDouble() -> Double? {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = CharacterSet.alphanumerics.inverted
        return scanner.scanDouble()
    }
}

/// Time Related
func formatTimeInterval(seconds: Int) -> String {
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24
    let months = days / 30
    let years = months / 12

    if years > 0 {
        return "\(years)y \(months % 12)m \(days % 30)d"
    } else if months > 0 {
        return "\(months)m \(days % 30)d"
    } else if days > 0 {
        return "\(days)d \(hours % 24)h"
    } else if hours > 0 {
        return "\(hours)h \(minutes % 60)m"
    } else if minutes > 0 {
        return "\(minutes)m \(seconds % 60)s"
    } else {
        return "\(seconds)s"
    }
}