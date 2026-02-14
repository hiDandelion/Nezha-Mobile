//
//  CronData.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 2/14/26.
//

import Foundation

struct CronData: Codable, Identifiable, Hashable {
    var id: String {
        String(cronID)
    }
    let cronID: Int64
    let name: String
    let taskType: CronTaskType
    let scheduler: String
    let command: String
    let coverageOption: Int64
    let serverIDs: [Int64]
    let notificationGroupID: Int64
    let pushSuccessful: Bool
    let lastExecutedAt: String
    let lastResult: Bool
    let cronJobID: Int64
}
