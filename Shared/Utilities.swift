//
//  Utilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation
import SwiftUI
#if os(iOS) || os(watchOS) || os(visionOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

// Debug Log
func debugLog(_ message: String) -> Any? {
    #if DEBUG
    print("Debug - \(message)")
    #endif
    return nil
}

// Bytes To Data Amount String
func formatBytes(_ bytes: Int64, decimals: Int = 2) -> String {
    let units = ["B", "KB", "MB", "GB", "TB", "PB"]
    var value = Double(bytes)
    var unitIndex = 0
    
    while value >= 1024 && unitIndex < units.count - 1 {
        value /= 1024
        unitIndex += 1
    }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = decimals
    formatter.roundingMode = .ceiling
    
    guard let formattedValue = formatter.string(from: NSNumber(value: value)) else {
        return ""
    }
    
    return "\(formattedValue) \(units[unitIndex])"
}

// Timestamp To Date String
func convertTimestampToLocalizedDateString(timestamp: Int64) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium

    let localizedDateString = formatter.string(from: date)
    return localizedDateString
}

// Seconds To Interval String
func formatTimeInterval(seconds: Int64, shortened: Bool = false) -> String {
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24

    func formatShort(_ unit: String, _ value: Int64) -> String {
        return String(format: NSLocalizedString("%lld%@", comment: "Short format: 5d"), value, NSLocalizedString(unit, comment: "Time unit"))
    }

    func formatLong(_ unit1: String, _ value1: Int64, _ unit2: String, _ value2: Int64) -> String {
        return String(format: NSLocalizedString("%lld%@%lld%@", comment: "Long format: 5d 3h"), value1, NSLocalizedString(unit1, comment: "Time unit 1"), value2, NSLocalizedString(unit2, comment: "Time unit 2"))
    }

    if days >= 10 {
        return formatShort("timeUnitShortened.d", days)
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
func isServerOnline(timestamp: Int64, lastUpdateTime: Date = Date()) -> Bool {
    let lastUpdateTimestamp = Int64(lastUpdateTime.timeIntervalSince1970)
    
    return lastUpdateTimestamp - timestamp > 60
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
extension Color: @retroactive RawRepresentable {
    public init?(base64EncodedString: String) {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            return nil
        }
        do {
#if os(iOS) || os(watchOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .white
#elseif os(macOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .white
#endif
            self = Color(color)
        } catch {
            return nil
        }
    }

    public var base64EncodedString: String? {
        do {
#if os(iOS) || os(watchOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
#elseif os(macOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
#endif

            return data.base64EncodedString()
        } catch {
            return nil
        }
    }
    
    // Compatible with AppStorage
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            return nil
        }
        do {
#if os(iOS) || os(watchOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .white
#elseif os(macOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .white
#endif
            self = Color(color)
        } catch {
            return nil
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
