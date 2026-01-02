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
        
        var settingRequest = URLRequest(url: settingConfiguration.url)
        var profileRequest = URLRequest(url: profileConfiguration.url)
        settingRequest.httpMethod = "GET"
        profileRequest.httpMethod = "GET"
        settingRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (settingData, _) = try await URLSession.shared.data(for: settingRequest)
        let (profileData, _) = try await URLSession.shared.data(for: profileRequest)
        
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
