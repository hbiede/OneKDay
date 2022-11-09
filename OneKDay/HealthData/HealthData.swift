/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of HealthKit properties, functions, and utilities.
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
    
    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    // MARK: - Authorization
    
    /// Request health data from HealthKit if needed, using the data types within `HealthData.allHealthDataTypes`
    class func requestHealthDataAccessIfNeeded(dataTypes: [String]? = nil, completion: @escaping (_ success: Bool) -> Void) {
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
    
    // MARK: - HKHealthStore
    
    class func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
    
    // MARK: - HKStatisticsCollectionQuery
    
    class func getHourlyStepCount(completion: @escaping ([StepEntry]) -> Void) {
        let startDate = Calendar.current.date(
            from: Calendar.current.dateComponents([.day, .month, .year, .hour], from: Date(timeIntervalSinceNow: -86400))
        )!
        return activitySteps(
            // Yesterday
            startDate,
            endDate: Date(),
            anchorDate: startDate,
            completion: completion
        )
    }

    class func activitySteps(
        _ startDate: Date,
        endDate: Date,
        anchorDate: Date,
        completion: @escaping ([StepEntry]) -> Void
    ) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let interval = NSDateComponents()
        interval.hour = 1

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: anchorDate, intervalComponents: interval as DateComponents)

        query.initialResultsHandler = { query, results, error in
          if let myResults = results{
            var stepsArray: [StepEntry] = []
            myResults.enumerateStatistics(from: startDate, to: endDate) {
              statistics, stop in

              if let quantity = statistics.sumQuantity() {
                let steps = quantity.doubleValue(for: HKUnit.count())

                let ret = StepEntry(stepCount: steps, startDate: statistics.startDate, endDate: statistics.endDate)
                stepsArray.append(ret)
              }
            }
            completion(stepsArray)
          }
        }

        healthStore.execute(query)
      }
}
