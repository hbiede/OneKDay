//
//  ChartUtils.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/9/22.
//

import Foundation
import SwiftUI

func getGoalComparisonColor(_ entry: Int, goal: Int) -> Color {
    return entry >= goal ? Color.green : Color.red
}

func formatDate(_ date: Date) -> String {
    let is12HourClock = NSLocale.current.hourCycle == .oneToTwelve
    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = is12HourClock ? "MMM d, h:mm a" : "MMM d, hh:mm"
        return temp
    }()
    return formatter.string(from: date)
}
