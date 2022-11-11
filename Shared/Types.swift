//
//  Types.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Foundation
import HealthKit

// swiftlint:disable identifier_name
let BACKGROUND_ID = "com.hbiede.OneKDay.notify"
let NOTIFICATION_UUID = "notificationUUID"
let STEP_COUNT_WIDGET_KIND = "StepCountWidget"
let STEP_GOAL_KEY = "stepGoal"
// swiftlint:enable identifier_name

struct MetricEntry {
    var metric: Double

    var startDate: Date

    var endDate: Date

    var type: HKQuantityTypeIdentifier
}
