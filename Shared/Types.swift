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

struct MetricEntry: Comparable,
                    AdditiveArithmetic,
                    Equatable,
                    ExpressibleByIntegerLiteral,
                    ExpressibleByFloatLiteral,
                    Hashable,
                    Codable {
    var metric: Double

    var startDate: Date

    var endDate: Date

    var type: HKQuantityTypeIdentifier

    typealias FloatLiteralType = Double
    typealias IntegerLiteralType = Int

    // MARK: Init
    init(
        metric: Double,
        startDate: Date,
        endDate: Date,
        type: HKQuantityTypeIdentifier
    ) {
        self.metric = metric
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }

    init(floatLiteral value: Double) {
        self.init(
            metric: value,
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 3600),
            type: .stepCount
        )
    }

    init(integerLiteral value: Int) {
        self.init(
            metric: Double(integerLiteral: Int64(value)),
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 3600),
            type: .stepCount
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metric = try container.decode(Double.self, forKey: .metric)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        type = HKQuantityTypeIdentifier(
            rawValue: try container.decode(String.self, forKey: .type)
        )
    }

    static var zero: MetricEntry = MetricEntry(
        metric: 0,
        startDate: Date(),
        endDate: Date(timeIntervalSinceNow: 3600),
        type: .stepCount
    )

    // MARK: Math Operations
    static func - (lhs: MetricEntry, rhs: MetricEntry) -> MetricEntry {
        MetricEntry(
            metric: lhs.metric - rhs.metric,
            startDate: [lhs.startDate, rhs.startDate].min(by: <)!,
            endDate: [lhs.endDate, rhs.endDate].min(by: <)!,
            type: lhs.type
        )
    }

    static func * (lhs: MetricEntry, rhs: MetricEntry) -> MetricEntry {
        MetricEntry(
            metric: lhs.metric * rhs.metric,
            startDate: [lhs.startDate, rhs.startDate].min(by: <)!,
            endDate: [lhs.endDate, rhs.endDate].min(by: <)!,
            type: lhs.type
        )
    }

    static func + (lhs: MetricEntry, rhs: MetricEntry) -> MetricEntry {
        MetricEntry(
            metric: lhs.metric + rhs.metric,
            startDate: [lhs.startDate, rhs.startDate].min(by: <)!,
            endDate: [lhs.endDate, rhs.endDate].min(by: <)!,
            type: lhs.type
        )
    }

    // MARK: Comparable
    static func == (lhs: MetricEntry, rhs: MetricEntry) -> Bool {
        lhs.type == rhs.type &&
            lhs.metric == rhs.metric &&
            lhs.startDate == rhs.startDate &&
            lhs.endDate == rhs.endDate
    }

    static func < (lhs: MetricEntry, rhs: MetricEntry) -> Bool {
        lhs.metric < rhs.metric
    }

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case metric, startDate, endDate, type
    }

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metric, forKey: .metric)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(type.rawValue, forKey: .type)
    }

    // MARK: Hashable
    var order: SortOrder = .forward
    func hash(into hasher: inout Hasher) {
        hasher.combine(metric)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(type.rawValue)
    }
}
