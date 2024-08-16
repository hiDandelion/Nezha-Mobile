//
//  Utilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import SwiftUI
#if os(iOS) || os(watchOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

/// Log Related
func debugLog(_ message: String) {
    #if DEBUG
    print("Debug - \(message)")
    #endif
}

/// Text Related
func formatBytes(_ bytes: Int) -> String {
    return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
}

func convertTimestampToLocalizedDateString(timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium

    let localizedDateString = formatter.string(from: date)
    return localizedDateString
}

func getCore(_ str: [String]?) -> String {
    guard let firstStr = str?.first else {
        return String(localized: "N/A")
    }
    
    let physicalCorePattern = #"(\d|\.)+ Physical"#
    let virtualCorePattern = #"(\d|\.)+ Virtual"#
    
    if let physicalCore = firstStr.range(of: physicalCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return physicalCore.replacingOccurrences(of: "Physical", with: String(localized: "Core"))
    } else if let virtualCore = firstStr.range(of: virtualCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return virtualCore.replacingOccurrences(of: "Virtual", with: String(localized: "Core"))
    } else {
        return String(localized: "N/A")
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
    
    func capitalizeFirstLetter() -> String {
        guard !self.isEmpty else { return self }
        return self.prefix(1).uppercased() + self.dropFirst()
    }
}

/// Time Related
func formatTimeInterval(seconds: Int, shortened: Bool = false) -> String {
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24
    let months = days / 30
    let years = months / 12

    if years > 0 {
        return "\(days)d"
    } else if months > 0 {
        return "\(days)d"
    } else if days > 0 {
        return shortened ? "\(days)d" : "\(days)d \(hours % 24)h"
    } else if hours > 0 {
        return shortened ? "\(hours)h" : "\(hours)h \(minutes % 60)m"
    } else if minutes > 0 {
        return shortened ? "\(minutes)m" : "\(minutes)m \(seconds % 60)s"
    } else {
        return "\(seconds)s"
    }
}

func isServerOnline(timestamp: Int) -> Bool {
    let currentTimestamp = Int(Date().timeIntervalSince1970)
    let fiveMinutesInSeconds = 60
    
    return currentTimestamp - timestamp > fiveMinutesInSeconds
}

/// View Related
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// Color Related
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .gray
            return
        }
        do {
#if os(iOS) || os(watchOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .white
#elseif os(macOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .white
#endif
            self = Color(color)
        } catch {
            self = .white
        }
    }

    public var rawValue: String {
        do {
#if os(iOS) || os(watchOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
#elseif os(macOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
#endif

            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
