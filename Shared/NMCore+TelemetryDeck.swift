//
//  NMCore+TelemetryDeck.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/24/25.
//

import TelemetryDeck

extension NMCore {
    static let telemetryDeckAppID = "46522000-F01B-47B0-A9E3-E70BB929F4A4"
    
    static func configureTelemetryDeck() {
        let config = TelemetryDeck.Config(appID: telemetryDeckAppID)
        TelemetryDeck.initialize(config: config)
    }
}
