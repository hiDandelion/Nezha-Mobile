//
//  TerminalView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import XTerminalUI

struct TerminalView: View {
    @StateObject var terminalViewModel: TerminalViewModel = TerminalViewModel()
    let host: String
    let port: Int
    let username: String
    let password: String?
    let privateKey: String?
    let privateKeyType: PrivateKeyType?
    
    var body: some View {
        VStack {
            switch(terminalViewModel.sshClientStatus) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded:
                terminalViewModel.terminalView
                    .onAppear {
                        terminalViewModel.setupTerminal(fontSize: 12)
                    }
            case .error(let message):
                Text(message)
            }
        }
        .onAppear {
            if let password {
                terminalViewModel.start(host: host, port: port, username: username, password: password)
            }
            if let privateKey, let privateKeyType {
                terminalViewModel.start(host: host, port: port, username: username, privateKey: privateKey, privateKeyType: privateKeyType)
            }
        }
        .onDisappear {
            terminalViewModel.shutdown()
        }
    }
}
