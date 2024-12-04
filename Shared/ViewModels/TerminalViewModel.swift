//
//  TerminalViewModel.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/4/24.
//

import Foundation
import SwiftUI
import Observation
import XTerminalUI

@Observable
class TerminalViewModel: NSObject, URLSessionWebSocketDelegate {
    var loadingState: LoadingState = .idle
    var keyCombination: KeyCombination = .none
    var terminalView: STerminalView?
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    
    func connect(serverID: Int64) {
        loadingState = .loading
        Task {
            do {
                let (response, token) = try await RequestHandler.getTerminalSession(serverID: serverID)
                let url = URL(string: "wss://\(NMCore.getNezhaDashboardLink())/api/v1/ws/terminal/\(response.data.session_id)")!
                
                var websocketRequest = URLRequest(url: url)
                websocketRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
                webSocketTask = session?.webSocketTask(with: websocketRequest)
                webSocketTask?.resume()
                receiveMessage()
                
                loadingState = .loaded
            }
            catch {
                DispatchQueue.main.async {
                    withAnimation {
                        self.loadingState = .error(error.localizedDescription)
                    }
                }
                return
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        terminalView = nil
        webSocketTask = nil
        session = nil
    }
    
    func setupTerminal(fontSize: Int) {
        terminalView = STerminalView()
        terminalView!.setTerminalFontSize(with: fontSize)
        terminalView!.setupBufferChain { [weak self] buffer in
            if [.control].contains(self?.keyCombination) {
                self?.sendCtrl(buffer)
                return
            }
            
            self?.sendMessage(buffer)
            return
        }
    }
    
    func sendCtrl(_ key: String) {
        guard key.count == 1 else { return }
        let character = Character(key.uppercased())
        guard let asciiValue = character.asciiValue,
              let asciiInt = Int(exactly: asciiValue)
        else {
            sendMessage(key)
            return
        }
        let ctrlInt = asciiInt - 64
        guard ctrlInt > 0, ctrlInt < 65 else {
            sendMessage(key)
            return
        }
        guard let unicodeScalar = UnicodeScalar(ctrlInt) else {
            sendMessage(key)
            return
        }
        let newCharacter = Character(unicodeScalar)
        let str = String(newCharacter)
        self.sendMessage(str)
        self.keyCombination = .none
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                _ = NMCore.debugLog("Terminal Error - \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleBinaryMessage(data)
                default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                _ = NMCore.debugLog("Terminal Error - \(error)")
            }
        }
    }
    
    private func handleBinaryMessage(_ data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            self.terminalView!.write(string)
            return
        }
        
        let hexString = data.map { String(format: "%02hhx", $0) }.joined()
        _ = NMCore.debugLog("Terminal Error - Unexpected data: \(hexString)")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        _ = NMCore.debugLog("Terminal Info - WebSocket connection established")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        _ = NMCore.debugLog("Terminal Info - WebSocket connection closed")
    }
}
