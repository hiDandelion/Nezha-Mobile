//
//  ServiceData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/9/24.
//

import Foundation
import SwiftyJSON

struct ServiceData: Identifiable, Hashable {
    var id: String {
        String(serviceID)
    }
    let serviceID: Int64
    let notificationGroupID: Int64
    let name: String
    let type: ServiceType
    let target: String
    let interval: Int64
    let minimumLatency: Int64
    let maximumLatency: Int64
    let coverageOption: Int64
    let excludeRule: JSON
    let failureTaskIDs: [Int64]?
    let recoverTaskIDs: [Int64]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(serviceID)
        hasher.combine(notificationGroupID)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(target)
        hasher.combine(interval)
        hasher.combine(minimumLatency)
        hasher.combine(maximumLatency)
        hasher.combine(coverageOption)
        hasher.combine(excludeRule.rawString())
        hasher.combine(failureTaskIDs)
        hasher.combine(recoverTaskIDs)
    }
}
