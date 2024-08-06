//
//  SocketHandler.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import Foundation

class GetServerDetailRequestHandler: NSObject, URLSessionWebSocketDelegate {
    static func getAllServerDetail(completion: @escaping (_ response: GetServerDetailResponse?, _ errorDescription: String?) -> Void) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.argsment.Nezha-Mobile"),
              let dashboardLink = userDefaults.string(forKey: "NMDashboardLink"),
              let dashboardAPIToken = userDefaults.string(forKey: "NMDashboardAPIToken"),
              let url = URL(string: "https://\(dashboardLink)/api/v1/server/details") else {
            print("Error obtaining connection info")
            completion(nil, String(localized: "error.invalidDashboardConfiguration"))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(dashboardAPIToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, String(localized: "error.errorReceivingData"))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GetServerDetailResponse.self, from: data)
                
                if response.result != nil {
                    completion(response, nil)
                    return
                }
                
                if response.code == 403 {
                    completion(nil, String(localized: "error.dashboardAuthenticationFailed"))
                    return
                }
                
                completion(nil, response.message)
                return
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type '\(type)' not found: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(nil, String(localized: "error.errorDecodingData"))
            }
        }
        .resume()
    }
}
