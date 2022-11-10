/*
 * A modified version of a file included in an Apple example project
 *
 * See LICENSE folder for this sample’s licensing information.
 *
 * Abstract:
 * A collection of utility functions used for displaying strings related to HealthKit.
 */

import Foundation
import HealthKit

// MARK: - Formatted Value Strings

/// Return a formatted readable value suitable for display for a health data value based
/// on its type. Example: "10,000 steps"
func formattedValue(_ value: Double, typeIdentifier: HKQuantityTypeIdentifier) -> String? {
    guard
        let unit = preferredUnit(for: typeIdentifier),
        let roundedValue = getRoundedValue(for: value, with: unit),
        let unitSuffix = getUnitSuffix(for: unit)
    else {
        return nil
    }

    let formattedString = String.localizedStringWithFormat("%@ %@", roundedValue, unitSuffix)

    return formattedString
}

private func getRoundedValue(for value: Double, with unit: HKUnit) -> String? {
    let numberFormatter = NumberFormatter()

    numberFormatter.numberStyle = .decimal

    switch unit {
    case .count(), .meter():
        let numberValue = NSNumber(value: round(value))

        return numberFormatter.string(from: numberValue)
    case .mile():
        let numberValue = NSNumber(value: round(value * 100) / 100)

        return numberFormatter.string(from: numberValue)
    default:
        return nil
    }
}

// MARK: - Units

func preferredUnit(for identifier: HKQuantityTypeIdentifier) -> HKUnit? {
    switch identifier {
    case .stepCount:
        return .count()
    case .distanceWalkingRunning:
        return Locale.current.measurementSystem == .metric ? .meter() : .mile()
    default:
        return nil
    }
}

func getUnitSuffix(for unit: HKUnit?) -> String? {
    if unit == nil {
        return nil
    }
    switch unit! {
    case .count():
        return "steps"
    case .mile():
        return "mi"
    case .meter():
        return "m"
    default:
        return nil
    }
}
