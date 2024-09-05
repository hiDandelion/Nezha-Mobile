//
//  SSHClient.swift
//  Sapient Shell
//
//  Created by Junhui Lou on 8/20/24.
//

import Foundation
import NIO
import NIOSSH
import Crypto

protocol SSHClientDelegate {
    func sendCommand(command: String)
    func receiveMessage(type: SSHMessageType,content: ByteBuffer)
    func updateStatus(status: SSHClientStatus)
}

class SSHClient {
    private let host: String
    private let port: Int
    private let authenticationMethod: SSHAuthenticationMethod
    private let group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var parentChannel: Channel?
    private var childChannel: Channel?
    var delegate: SSHClientDelegate?
    
    init(host: String, port: Int = 22, authenticationMethod: SSHAuthenticationMethod) {
        self.host = host
        self.port = port
        self.authenticationMethod = authenticationMethod
    }
    
    func shutdown() {
        if self.childChannel != nil {
            self.childChannel?.close().whenComplete { [weak self] _ in
                self?.parentChannel?.close().whenComplete { [weak self] _ in
                    self?.parentChannel = nil
                    self?.childChannel = nil
                }
            }
        }
        else {
            self.parentChannel?.close().whenComplete { [weak self] _ in
                self?.parentChannel = nil
            }
        }
    }
    
    func connect() -> EventLoopFuture<Channel> {
        let bootstrap = ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_KEEPALIVE), value: 1)
            .channelInitializer { channel in
                return channel.pipeline.addHandler(
                    NIOSSHHandler(
                        role: .client(.init(
                            userAuthDelegate: self.authenticationMethod,
                            serverAuthDelegate: AcceptAllServerAuthenticationDelegate()
                        )),
                        allocator: ByteBufferAllocator(),
                        inboundChildChannelInitializer: nil
                    )
                )
            }
        return bootstrap.connect(host: host, port: port)
    }
    
    func run(command: String?) {
        if let childChannel, childChannel.isActive, let command {
            let buffer = childChannel.allocator.buffer(string: command)
            childChannel.writeAndFlush(buffer)
                .whenComplete{ result in
                    switch result {
                    case .success:
                        _ = debugLog("Channel Info - Command sent successfully")
                    case .failure(let error):
                        _ = debugLog("Channel Error - Failed to send command: \(error)")
                    }
                }
        }
        else {
            connect().flatMap { parentChannel in
                self.parentChannel = parentChannel
                return parentChannel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                    let createChannelPromise = parentChannel.eventLoop.makePromise(of: Channel.self)
                    sshHandler.createChannel(createChannelPromise) { childChannel, channelType in
                        self.childChannel = childChannel
                        return childChannel.pipeline.addHandlers([
                            SSHChannelHandler(delegate: self.delegate),
                            SSHInteractiveHandler(delegate: self.delegate)
                        ])
                    }
                    parentChannel.eventLoop.scheduleTask(in: .seconds(10)) {
                        createChannelPromise.fail(SSHClientError.channelCreationFailed)
                    }
                    return createChannelPromise.futureResult.flatMap { _ in
                        return parentChannel.eventLoop.makeSucceededFuture((parentChannel))
                    }
                }
            }
            .whenComplete { result in
                switch result {
                case .success(let channel):
                    _ = debugLog("Channel Info - \(channel)")
                    if let command {
                        self.run(command: command)
                    }
                case .failure(let error):
                    self.delegate?.updateStatus(status: .error("\(error.localizedDescription)"))
                    _ = debugLog("Channel Error - \(error)")
                }
            }
        }
    }
    
    func windowChange(width: Int, height: Int) {
        if let childChannel, childChannel.isActive {
            let windowChangeRequest = SSHChannelRequestEvent.WindowChangeRequest(
                terminalCharacterWidth: 80,
                terminalRowHeight: 24,
                terminalPixelWidth: width,
                terminalPixelHeight: height
            )
            childChannel.triggerUserOutboundEvent(windowChangeRequest)
                .whenComplete{ result in
                    switch result {
                    case .success:
                        _ = debugLog("Channel Info - Window changed successfully")
                    case .failure(let error):
                        _ = debugLog("Channel Error - Failed to change window: \(error)")
                    }
                }
        }
        else {
            _ = debugLog("No active channel")
        }
    }
}

struct AcceptAllServerAuthenticationDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        // Warning: This accepts all host keys without verification.
        validationCompletePromise.succeed(())
    }
}

class SSHChannelHandler: ChannelDuplexHandler {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData
    
    private var delegate: SSHClientDelegate?
    
    init(delegate: SSHClientDelegate?) {
        self.delegate = delegate
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        _ = debugLog("Channel Handler Info - Channel read start")
        let channelData = self.unwrapInboundIn(data)
        
        switch channelData.type {
        case .channel:
            guard case .byteBuffer(let buffer) = channelData.data else {
                _ = debugLog("Channel Handler Error - Unexpected channel data")
                return
            }
            context.fireChannelRead(self.wrapInboundOut(buffer))
        case .stdErr:
            guard case .byteBuffer(let buffer) = channelData.data else {
                _ = debugLog("Channel Handler Error - Unexpected channel data")
                return
            }
            self.delegate?.receiveMessage(type: .stderr, content: buffer)
            _ = debugLog("Channel Handler Info - stderr received")
        default:
            _ = debugLog("Channel Handler Error - Unexpected SSH channel data type")
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        _ = debugLog("Channel Handler Info - Write to outbound data")
        let buffer = self.unwrapOutboundIn(data)
        context.write(self.wrapOutboundOut(.init(type: .channel, data: .byteBuffer(buffer))), promise: promise)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        _ = debugLog("Channel Handler Error - Error caught: \(error)")
        context.close(promise: nil)
    }
}

class SSHInteractiveHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    
    private var delegate: SSHClientDelegate?
    
    init(delegate: SSHClientDelegate?) {
        self.delegate = delegate
    }
    
    func channelActive(context: ChannelHandlerContext) {
        let pseudoTerminalRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true,
            term: "xterm",
            terminalCharacterWidth: 80,
            terminalRowHeight: 24,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: .init([
                .ECHO: 1,      // Enable local echo
                .ICANON: 1,    // Enable canonical mode (line-by-line input)
                .ICRNL: 1,     // Map CR to NL on input
                .ONLCR: 1,     // Map NL to CR-NL on output
                .ISIG: 1,      // Enable signals
                .IEXTEN: 1,    // Enable extensions
                .OPOST: 1,     // Enable output processing
                .CS8: 1,       // 8 bit mode
                .IGNPAR: 0,    // Don't ignore parity errors
                .VEOF: 4,      // EOF character (usually Ctrl-D)
                .VERASE: 0x7f, // Erase character (usually backspace)
                .VINTR: 3,     // Interrupt character (usually Ctrl-C)
                .VKILL: 21,    // Kill line character (usually Ctrl-U)
                .VQUIT: 28,    // Quit character (usually Ctrl-\)
                .VSTART: 17,   // Start character (usually Ctrl-Q)
                .VSTOP: 19     // Stop character (usually Ctrl-S)
            ])
        )
        context.triggerUserOutboundEvent(pseudoTerminalRequest)
            .whenComplete { result in
                switch result {
                case .success(let channel):
                    _ = debugLog("Channel Info - Pseudo Terminal created")
                    self.delegate?.updateStatus(status: .loaded)
                    let shellRequest = SSHChannelRequestEvent.ShellRequest(wantReply: true)
                    context.triggerUserOutboundEvent(shellRequest, promise: nil)
                case .failure(let error):
                    _ = debugLog("Channel Error - \(error)")
                }
            }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        self.delegate?.receiveMessage(type: .stdout, content: buffer)
        _ = debugLog("Interactive Handler Info - stdout received")
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        _ = debugLog("Interactive Handler Info - Event: \(event)")
    }
}
