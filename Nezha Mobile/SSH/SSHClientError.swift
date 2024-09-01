//
//  SSHClientError.swift
//  Sapient Shell
//
//  Created by Junhui Lou on 8/28/24.
//

import Foundation

public enum SSHClientError: Error {
    case unsupportedPasswordAuthentication, unsupportedHostBasedAuthentication, unsupportedPrivateKeyAuthentication
    case channelCreationFailed
    case allAuthenticationOptionsFailed
}
