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

// Debug Log
func debugLog(_ message: String) {
    #if DEBUG
    print("Debug - \(message)")
    #endif
}

// Bytes To Data Amount String
func formatBytes(_ bytes: Int) -> String {
    return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
}

// Timestamp To Date String
func convertTimestampToLocalizedDateString(timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium

    let localizedDateString = formatter.string(from: date)
    return localizedDateString
}

// Seconds To Interval String
func formatTimeInterval(seconds: Int, shortened: Bool = false) -> String {
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24
    let months = days / 30
    let years = months / 12

    let formatShort: (String, Int) -> String = { unit, value in
        return String(format: NSLocalizedString("%d%@", comment: "Short format: 5d"), value, NSLocalizedString(unit, comment: "Time unit"))
    }

    let formatLong: (String, Int, String, Int) -> String = { unit1, value1, unit2, value2 in
        return String(format: NSLocalizedString("%d%@ %d%@", comment: "Long format: 5d 3h"), value1, NSLocalizedString(unit1, comment: "Time unit 1"), value2, NSLocalizedString(unit2, comment: "Time unit 2"))
    }

    if years > 0 {
        return shortened ? formatShort("timeUnitShortened.y", years) : formatLong("timeUnitShortened.y", years, "timeUnitShortened.mo", months % 12)
    } else if months > 0 {
        return shortened ? formatShort("timeUnitShortened.mo", months) : formatLong("timeUnitShortened.mo", months, "timeUnitShortened.d", days % 30)
    } else if days > 0 {
        return shortened ? formatShort("timeUnitShortened.d", days) : formatLong("timeUnitShortened.d", days, "timeUnitShortened.h", hours % 24)
    } else if hours > 0 {
        return shortened ? formatShort("timeUnitShortened.h", hours) : formatLong("timeUnitShortened.h", hours, "timeUnitShortened.m", minutes % 60)
    } else if minutes > 0 {
        return shortened ? formatShort("timeUnitShortened.m", minutes) : formatLong("timeUnitShortened.m", minutes, "timeUnitShortened.s", seconds % 60)
    } else {
        return formatShort("timeUnitShortened.s", seconds)
    }
}

// Extract Core Count From CPU Information
func getCore(_ str: [String]?) -> Int? {
    guard let firstStr = str?.first else {
        return nil
    }
    
    let physicalCorePattern = #"(\d|\.)+ Physical"#
    let virtualCorePattern = #"(\d|\.)+ Virtual"#
    
    if let physicalCore = firstStr.range(of: physicalCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return physicalCore.extractFirstNumber()
    } else if let virtualCore = firstStr.range(of: virtualCorePattern, options: .regularExpression).map({ String(firstStr[$0]) }) {
        return virtualCore.extractFirstNumber()
    } else {
        return nil
    }
}

// Country Code To Emoji
func countryFlagEmoji(countryCode: String) -> String {
    let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    
    return countryCode
        .uppercased()
        .unicodeScalars
        .map { String(UnicodeScalar(base + $0.value)!) }
        .joined()
}

// Server Online Indicator
func isServerOnline(timestamp: Int) -> Bool {
    let currentTimestamp = Int(Date().timeIntervalSince1970)
    let fiveMinutesInSeconds = 60
    
    return currentTimestamp - timestamp > fiveMinutesInSeconds
}

// Capitalizer
extension String {
    func extractFirstNumber() -> Int? {
        let pattern = "\\d+"
        if let range = self.range(of: pattern, options: .regularExpression) {
            let numberString = String(self[range])
            return Int(numberString)
        }
        return nil
    }
    
    func capitalizeFirstLetter() -> String {
        guard !self.isEmpty else { return self }
        return self.prefix(1).uppercased() + self.dropFirst()
    }
}

// "if" Modifier
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// Color String Unarchiver
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
