//
//  TerminalViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 9/1/24.
//

import Foundation
import NIO
import CryptoKit
import XTerminalUI

enum SSHClientStatus: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

class SSHMessage {
    let id: UUID
    let timestamp: Date
    let type: SSHMessageType
    let content: String
    
    init(id: UUID, timestamp: Date, type: SSHMessageType, content: String) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.content = content
    }
}

enum SSHMessageType {
    case stdin
    case stdout
    case stderr
}

class TerminalViewModel: ObservableObject, SSHClientDelegate {
    let terminalView: STerminalView = STerminalView()
    private var sshClient: SSHClient?
    @Published var sshClientStatus: SSHClientStatus = .idle
    @Published var keyCombination: KeyCombination = .none
    
    // MARK: - Terminal View Related
    
    func setupTerminal(fontSize: Int) {
        terminalView.setTerminalFontSize(with: fontSize)
        terminalView.setupBufferChain { [weak self] buffer in
            if [.control].contains(self?.keyCombination) {
                self?.sendCtrl(buffer)
                return
            }
                
            self?.sendCommand(command: buffer)
            return
        }
    }
    
    func sendCtrl(_ key: String) {
        guard key.count == 1 else { return }
        let character = Character(key.uppercased())
        guard let asciiValue = character.asciiValue,
              let asciiInt = Int(exactly: asciiValue)
        else {
            sendCommand(command: key)
            return
        }
        let ctrlInt = asciiInt - 64
        guard ctrlInt > 0, ctrlInt < 65 else {
            sendCommand(command: key)
            return
        }
        guard let unicodeScalar = UnicodeScalar(ctrlInt) else {
            sendCommand(command: key)
            return
        }
        let newCharacter = Character(unicodeScalar)
        let str = String(newCharacter)
        self.sendCommand(command: str)
        self.keyCombination = .none
    }
    
    // MARK: - SSH Related
    
    func sendCommand(command: String) {
        self.sshClient?.run(command: command)
    }
    
    func receiveMessage(type: SSHMessageType, content: ByteBuffer) {
        var byteBuffer = content
        if let contentString = byteBuffer.readString(length: content.readableBytes) {
            DispatchQueue.main.async {
                self.terminalView.write(contentString)
            }
        }
    }
    
    func updateStatus(status: SSHClientStatus) {
        DispatchQueue.main.async {
            self.sshClientStatus = status
        }
    }
    
    func start(host: String, port: Int = 22, username: String, password: String) {
        self.sshClientStatus = .loading
        self.sshClient = SSHClient(host: host, port: port, authenticationMethod: SSHAuthenticationMethod(username: username, offer: .password(.init(password: password))))
        self.sshClient?.delegate = self
        self.sshClient?.run(command: nil)
    }
    
    func start(host: String, port: Int = 22, username: String, privateKey: String, privateKeyType: PrivateKeyType) {
        self.sshClientStatus = .loading
        switch(privateKeyType) {
        case .ed25519:
            let privateKeyData = try! decodeOpenSSHED25519KeyToCurve25519(openSSHED25519Key: privateKey)
            self.sshClient = SSHClient(host: host, port: port, authenticationMethod: .ed25519(username: username, privateKey: privateKeyData))
        case .p256:
            let privateKeyData = try! decodeP256Key(p256Key: privateKey)
            self.sshClient = SSHClient(host: host, port: port, authenticationMethod: .p256(username: username, privateKey: privateKeyData))
        case .p384:
            let privateKeyData = try! decodeP384Key(p384Key: privateKey)
            self.sshClient = SSHClient(host: host, port: port, authenticationMethod: .p384(username: username, privateKey: privateKeyData))
        case .p521:
            let privateKeyData = try! decodeP521Key(p521Key: privateKey)
            self.sshClient = SSHClient(host: host, port: port, authenticationMethod: .p521(username: username, privateKey: privateKeyData))
        }
        self.sshClient?.delegate = self
        self.sshClient?.run(command: nil)
    }
    
    func shutdown() {
        self.sshClient?.shutdown()
        self.sshClient = nil
        self.sshClientStatus = .idle
    }
}
