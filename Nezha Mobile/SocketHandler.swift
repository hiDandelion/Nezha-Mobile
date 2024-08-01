//
//  SocketHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation

struct SocketResponse: Codable {
    let now: Int
    let servers: [Server]
}

struct Server: Codable {
    let id: Int
    let name: String
    let tag: String
    let host: ServerHost
    let state: ServerState
    let lastActive: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case tag = "Tag"
        case host = "Host"
        case state = "State"
        case lastActive = "LastActive"
    }
}

struct ServerHost: Codable {
    let platform: String
    let platformVersion: String
    let cpu: [String]?
    let memTotal: Int
    let swapTotal: Int
    let diskTotal: Int
    let bootTime: Int
    let countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case platform = "Platform"
        case platformVersion = "PlatformVersion"
        case cpu = "CPU"
        case memTotal = "MemTotal"
        case swapTotal = "SwapTotal"
        case diskTotal = "DiskTotal"
        case bootTime = "BootTime"
        case countryCode = "CountryCode"
    }
}

struct ServerState: Codable {
    let cpu: Double
    let memUsed: Int
    let swapUsed: Int
    let diskUsed: Int
    let netInTransfer: Int
    let netOutTransfer: Int
    let netInSpeed: Int
    let netOutSpeed: Int
    let load1: Double
    let load5: Double
    let load15: Double
    
    enum CodingKeys: String, CodingKey {
        case cpu = "CPU"
        case memUsed = "MemUsed"
        case swapUsed = "SwapUsed"
        case diskUsed = "DiskUsed"
        case netInTransfer = "NetInTransfer"
        case netOutTransfer = "NetOutTransfer"
        case netInSpeed = "NetInSpeed"
        case netOutSpeed = "NetOutSpeed"
        case load1 = "Load1"
        case load5 = "Load5"
        case load15 = "Load15"
    }
}

protocol SocketHandlerDelegate: AnyObject {
    func didReceiveServerResponse(_ socketResponse: SocketResponse)
    func didEncounterError(_ error: Error)
}

class SocketHandler: NSObject, URLSessionWebSocketDelegate {
    weak var delegate: SocketHandlerDelegate?
    private var webSocket: URLSessionWebSocketTask?
    private var connectionTimer: Timer?
    private let timeoutInterval: TimeInterval = 5.0
    var isConnected = false
    
    func connect(to url: URL) {
        guard !isConnected else { return }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        connectionTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            self?.handleConnectionTimeout()
        }
        isConnected = true
    }
    
    private func handleConnectionTimeout() {
        let error = NSError(domain: "WebSocketManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection timeout. Verify your server link and network connection."])
        delegate?.didEncounterError(error)
        disconnect()
    }
    
    func send(message: String) {
        webSocket?.send(.string(message)) { error in
            if let error = error {
                print("Error sending WebSocket message: \(error)")
                self.delegate?.didEncounterError(error)
            }
        }
    }
    
    func receive() {
        webSocket?.receive { result in
            switch result {
            case .failure(let error):
                if (error as NSError).domain == NSPOSIXErrorDomain && (error as NSError).code == 57 {
                    self.isConnected = false
                } else {
                    self.delegate?.didEncounterError(error)
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleServerResponse(text)
                case .data(let data):
                    self.handleServerResponse(data: data)
                @unknown default:
                    break
                }
            }
            self.receive()
        }
    }
    
    private func handleServerResponse(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("Error converting text to data")
            return
        }
        handleServerResponse(data: data)
    }
    
    private func handleServerResponse(data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(SocketResponse.self, from: data)
            delegate?.didReceiveServerResponse(response)
        } catch {
            print("Error decoding JSON: \(error)")
            delegate?.didEncounterError(error)
        }
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        connectionTimer?.invalidate()
        connectionTimer = nil
        isConnected = false
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connectionTimer?.invalidate()
        connectionTimer = nil
        receive()
        print("WebSocket connection established")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed")
    }
}
