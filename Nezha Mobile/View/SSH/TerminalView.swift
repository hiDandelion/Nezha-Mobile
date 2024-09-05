//
//  TerminalView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import SwiftUI
import XTerminalUI

enum KeyCombination {
    case none
    case control
}

struct TerminalView: View {
    @Environment(\.displayScale) var displayScale
    @StateObject var terminalViewModel: TerminalViewModel = TerminalViewModel()
    let host: String
    let port: Int
    let username: String
    let password: String?
    let privateKey: String?
    let privateKeyType: PrivateKeyType?
    
    var body: some View {
        NavigationStack {
            VStack {
                switch(terminalViewModel.sshClientStatus) {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .loaded:
                    GeometryReader { proxy in
                        VStack {
                            terminalViewModel.terminalView
                                .onChange(of: proxy.size) {
                                    terminalViewModel.updateTerminalSize(width: proxy.size.width * displayScale, height: proxy.size.height * displayScale)
                                }
                                .onKeyPress { press in
                                    switch(press.key) {
                                    case .upArrow:
                                        writeBase64("G1tB")
                                        return .handled
                                    case .downArrow:
                                        writeBase64("G1tC")
                                        return .handled
                                    case .leftArrow:
                                        writeBase64("G1tE")
                                        return .handled
                                    case.rightArrow:
                                        writeBase64("G1tD")
                                        return .handled
                                    default:
                                        ()
                                    }
                                    
                                    switch(press.modifiers) {
                                    case .control:
                                        terminalViewModel.sendCtrl(press.characters)
                                        return .handled
                                    default:
                                        ()
                                    }
                                    
                                    write(press.characters)
                                    return .handled
                                }
                                .onAppear {
                                    terminalViewModel.setupTerminal(fontSize: 12)
                                    terminalViewModel.updateTerminalSize(width: proxy.size.width * displayScale, height: proxy.size.height * displayScale)
                                }
                        }
                    }
                    buttonGroup
                case .error(let message):
                    Text(message)
                }
            }
            .navigationTitle("Terminal")
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
    
    var buttonGroup: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom) {
                Group {
                    makeKeyboardFloatingButton("doc.on.clipboard") {
                        guard let str = UIPasteboard.general.string else {
                            return
                        }
                        write(str)
                    }
                }
                
                Group {
                    makeKeyboardFloatingButton("arrowtriangle.up.fill") {
                        writeBase64("G1tB")
                    }
                    makeKeyboardFloatingButton("arrowtriangle.down.fill") {
                        writeBase64("G1tC")
                    }
                    makeKeyboardFloatingButton("arrowtriangle.backward.fill") {
                        writeBase64("G1tE")
                    }
                    makeKeyboardFloatingButton("arrowtriangle.right.fill") {
                        writeBase64("G1tD")
                    }
                }
                
                Group {
                    makeKeyboardFloatingButton("escape") {
                        writeBase64("Gw==")
                    }
                    if [.control].contains(terminalViewModel.keyCombination) {
                        makeKeyboardFloatingButtonProminent("control") {
                            terminalViewModel.keyCombination = .none
                        }
                    }
                    else {
                        makeKeyboardFloatingButton("control") {
                            terminalViewModel.keyCombination = .control
                        }
                    }
                    makeKeyboardFloatingButton("arrow.right.to.line.compact") {
                        writeBase64("CQ==")
                    }
                }
            }
        }
        .scrollIndicators(.never)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    func makeKeyboardFloatingButton(_ systemImage: String, execution: @escaping () -> Void) -> some View {
        Button {
            execution()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.bordered)
    }
    
    func makeKeyboardFloatingButtonProminent(_ systemImage: String, execution: @escaping () -> Void) -> some View {
        Button {
            execution()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.borderedProminent)
    }
    
    func write(_ str: String) {
        terminalViewModel.sendCommand(command: str)
    }
    
    func writeBase64(_ base64: String) {
        guard let data = Data(base64Encoded: base64),
              let command = String(data: data, encoding: .utf8)
        else {
            return
        }
        terminalViewModel.sendCommand(command: command)
    }
}
