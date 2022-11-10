/*
 * A modified version of a file included in an Apple example project
 *
 * See LICENSE folder for this sample’s licensing information.
 *
 * Abstract:
 * A collection of HealthKit properties, functions, and utilities.
 */

import Foundation
import HealthKit

class HealthData {

    static let healthStore: HKHealthStore = HKHealthStore()

    // MARK: - Data Types

    static var readDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }

    static var shareDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }

    static let measurableHealthMetrics: [HKQuantityTypeIdentifier] = [
        .stepCount,
        .distanceWalkingRunning
    ]

    private static var allHealthDataTypes: [HKSampleType] =
        measurableHealthMetrics.compactMap { getSampleType(for: $0.rawValue) }

    // MARK: - Authorization

    /// Request health data from HealthKit if needed, using the data types within `HealthData.allHealthDataTypes`
    class func requestHealthDataAccessIfNeeded(
        dataTypes: [String]? = nil,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        var readDataTypes = Set(allHealthDataTypes)
        let shareData: [HKSampleType] = []
        var shareDataTypes = Set(shareData)

        if let dataTypeIdentifiers = dataTypes {
            readDataTypes = Set(dataTypeIdentifiers.compactMap { getSampleType(for: $0) })
            shareDataTypes = readDataTypes
        }

        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }

    /// Request health data from HealthKit if needed.
    class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                               read readTypes: Set<HKObjectType>?,
                                               completion: @escaping (_ success: Bool) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("Health data is not available!")
        }

        print("Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            if let error = error {
                print("requestAuthorization error:", error.localizedDescription)
            }

            if success {
                print("HealthKit authorization request was successful!")
            } else {
                print("HealthKit authorization was not successful.")
            }

            completion(success)
        }
    }

    // MARK: - HKStatisticsCollectionQuery

    class func getHourlyMetricCount(
            for identifier: HKQuantityTypeIdentifier,
            completion: @escaping ([MetricEntry]
        ) -> Void) {
            // Yesterday
            let startDate = Calendar.current.date(
                from: Calendar.current.dateComponents(
                    [.day, .month, .year, .hour],
                    from: Date(timeIntervalSinceNow: -86400)
                )
            )!
            return activityMetrics(
                startDate,
                endDate: Date(),
                anchorDate: startDate,
                identifier: identifier,
                completion: completion
            )
    }

    class func activityMetrics(
        _ startDate: Date,
        endDate: Date,
        anchorDate: Date,
        identifier: HKQuantityTypeIdentifier = .stepCount,
        completion: @escaping ([MetricEntry]) -> Void
    ) {
        let type = HKSampleType.quantityType(forIdentifier: identifier)
        let interval = NSDateComponents()
        interval.hour = 1

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: type!,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum],
            anchorDate: anchorDate,
            intervalComponents: interval as DateComponents
        )

        query.initialResultsHandler = { _, results, _ in
          if let myResults = results {
            var stepsArray: [MetricEntry] = []
            myResults.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    stepsArray.append(
                        MetricEntry(
                            metric: quantity.doubleValue(
                                for: preferredUnit(
                                    for: identifier
                                )!
                            ),
                            startDate: statistics.startDate,
                            endDate: statistics.endDate,
                            type: identifier
                        )
                    )
                }
            }
            completion(stepsArray)
          }
        }

        healthStore.execute(query)
      }
}

func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }

    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }

    return nil
}


