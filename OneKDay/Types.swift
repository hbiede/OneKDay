//
//  Types.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Foundation

let BACKGROUND_ID = "com.hbiede.OneKDay.notify"
let NOTIFICATION_UUID = "notificationUUID"
let STEP_GOAL_KEY = "stepGoal"

struct StepEntry {
    var stepCount: Double
    
    var startDate: Date
    
    var endDate: Date
}
