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
    @StateObject var terminalViewModel: TerminalViewModel = TerminalViewModel()
    let host: String
    let port: Int
    let username: String
    let password: String?
    let privateKey: String?
    let privateKeyType: PrivateKeyType?
    
    @State var keyCombination: KeyCombination = .none
    
    var body: some View {
        VStack {
            switch(terminalViewModel.sshClientStatus) {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded:
                terminalViewModel.terminalView
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
                            sendCtrl(press.characters)
                            keyCombination = .none
                            return .handled
                        default:
                            ()
                        }
                        
                        switch(keyCombination) {
                        case .none:
                            terminalViewModel.sendCommand(command: press.characters)
                            return .handled
                        case .control:
                            sendCtrl(press.characters)
                            keyCombination = .none
                            return .handled
                        }
                    }
                    .onAppear {
                        terminalViewModel.setupTerminal(fontSize: 12)
                    }
                buttonGroup
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
    
    var buttonGroup: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom) {
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
                    if [.control].contains(keyCombination) {
                        makeKeyboardFloatingButtonProminent("control") {
                            keyCombination = .control
                        }
                    }
                    else {
                        makeKeyboardFloatingButton("control") {
                            keyCombination = .control
                        }
                    }
                }
            }
        }
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
    
    func writeBase64(_ base64: String) {
        guard let data = Data(base64Encoded: base64),
              let command = String(data: data, encoding: .utf8)
        else {
            return
        }
        terminalViewModel.sendCommand(command: command)
    }
    
    func sendCtrl(_ key: String) {
        guard key.count == 1 else { return }
        let character = Character(key.uppercased())
        guard let asciiValue = character.asciiValue,
              let asciiInt = Int(exactly: asciiValue)
        else {
            return
        }
        let ctrlInt = asciiInt - 64
        guard ctrlInt > 0, ctrlInt < 65 else {
            return
        }
        guard let unicodeScalar = UnicodeScalar(ctrlInt) else {
            return
        }
        let newCharacter = Character(unicodeScalar)
        let str = String(newCharacter)
        terminalViewModel.sendCommand(command: str)
    }
}
