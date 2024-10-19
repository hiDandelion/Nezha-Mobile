//
//  NezhaWatchApp.swift
//  Nezha Watch
//
//  Created by Junhui Lou on 8/9/24.
//

import SwiftUI

@main
struct NezhaWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        NMCore.registerUserDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
