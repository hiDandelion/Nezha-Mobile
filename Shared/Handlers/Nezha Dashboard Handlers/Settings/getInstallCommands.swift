//
//  getInstallCommands.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/2/26.
//

import Foundation

extension RequestHandler {
    static func getInstallCommands() async throws -> (String, String, String) {
        guard let settingConfiguration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/setting") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        guard let profileConfiguration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/profile") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }
        
        let loginResponse = try await login()
        guard let token = loginResponse.data?.token else {
            _ = NMCore.debugLog("Login Error - Cannot get token")
            throw NezhaDashboardError.dashboardAuthenticationFailed
        }
        
        let settingRequest: URLRequest = {
            var request = URLRequest(url: settingConfiguration.url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }()
        
        let profileRequest: URLRequest = {
            var request = URLRequest(url: profileConfiguration.url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }()
        
        async let settingResult = URLSession.shared.data(for: settingRequest)
        async let profileResult = URLSession.shared.data(for: profileRequest)
        
        let (settingData, _) = try await settingResult
        let (profileData, _) = try await profileResult
        
        let getSettingResponse: GetSettingResponse = try decodeNezhaDashboardResponse(data: settingData)
        let getProfileResponse: GetProfileResponse = try decodeNezhaDashboardResponse(data: profileData)
        
        let installHost = getSettingResponse.data!.config.install_host
        let agentSecret = getProfileResponse.data!.agent_secret
        
        let linuxCommand = "curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh && env NZ_SERVER=\(installHost) NZ_TLS=false NZ_CLIENT_SECRET=\(agentSecret) ./agent.sh"
        let macOSCommand = "curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh && env NZ_SERVER=\(installHost) NZ_TLS=false NZ_CLIENT_SECRET=\(agentSecret) ./agent.sh"
        let windowsCommand = "$env:NZ_SERVER=\"\(installHost)\";$env:NZ_TLS=\"false\";$env:NZ_CLIENT_SECRET=\"\(agentSecret)\"; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3 -bor [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12;set-ExecutionPolicy RemoteSigned;Invoke-WebRequest https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.ps1 -OutFile C:install.ps1;powershell.exe C:install.ps1"
        
        return (linuxCommand, macOSCommand, windowsCommand)
    }
}
