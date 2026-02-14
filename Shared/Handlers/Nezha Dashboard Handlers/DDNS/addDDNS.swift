//
//  addDDNS.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

extension RequestHandler {
    static func addDDNS(name: String, provider: String, domains: [String], accessID: String, accessSecret: String, enableIPv4: Bool, enableIPv6: Bool, maxRetries: Int64, webhookURL: String, webhookMethod: Int64, webhookRequestType: Int64, webhookRequestBody: String, webhookHeaders: String) async throws -> AddDDNSResponse {
        guard let configuration = NMCore.getNezhaDashboardConfiguration(endpoint: "/api/v1/ddns") else {
            throw NezhaDashboardError.invalidDashboardConfiguration
        }

        let token = try await getToken()

        var request = URLRequest(url: configuration.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "name": name,
            "provider": provider,
            "domains": domains,
            "access_id": accessID,
            "access_secret": accessSecret,
            "enable_ipv4": enableIPv4,
            "enable_ipv6": enableIPv6,
            "max_retries": maxRetries,
            "webhook_url": webhookURL,
            "webhook_method": webhookMethod,
            "webhook_request_type": webhookRequestType,
            "webhook_request_body": webhookRequestBody,
            "webhook_headers": webhookHeaders
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try decodeNezhaDashboardResponse(data: data)
    }
}
