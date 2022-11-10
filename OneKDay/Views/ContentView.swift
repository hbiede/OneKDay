//
//  ContentView.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Charts
import HealthKit
import SwiftUI

let metricOptions: [HKQuantityTypeIdentifier] = HealthData.measurableHealthMetrics

struct ContentView: View {
    private let userDefaults = UserDefaults()

    @State private var currentMetricIndex: Int = 0
    @State private var metricTotals: [HKQuantityTypeIdentifier: Double] = [metricOptions[0]: 0.0]
    @State private var metricCounts: [HKQuantityTypeIdentifier: [MetricEntry]] = [
        metricOptions[0]: []
    ]
    @State private var showingSheet = false
    @AppStorage(STEP_GOAL_KEY) var stepGoal = 0

    @ViewBuilder
    var body: some View {
        let metricID = metricOptions[currentMetricIndex]
        let currentMetricList = metricCounts[metricID, default: []]
        if !HKHealthStore.isHealthDataAvailable() {
            Text("Enable access to step count")
        } else {
            NavigationView {
                VStack {
                    if !currentMetricList.isEmpty {
                        Chart(currentMetricList, id: \.startDate) {
                            BarMark(
                                x: .value("Time", $0.startDate, unit: .hour),
                                y: .value(
                                        getUnitSuffix(
                                            for: preferredUnit(
                                                for: metricID
                                            )
                                        )?.capitalized(with: Locale.current) ?? "Measurement",
                                        $0.metric
                                    )
                            )
                            .foregroundStyle(getBarGraphStyle(for: $0.metric))
                                .accessibilityLabel(formatDate($0.startDate))
                                .accessibilityValue(formattedValue(
                                    $0.metric,
                                    typeIdentifier: metricID
                                ) ?? "X")
                            if currentMetricIndex == 0 {
                                RuleMark(
                                    y: .value("Goal", stepGoal)
                                )
                                    .accessibilityLabel("Goal")
                                    .accessibilityValue(formattedValue(
                                        Double(stepGoal),
                                        typeIdentifier: metricID
                                    ) ?? "X")
                            }
                        }
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        
                        Subtitle
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                .navigationTitle("OneK Day")
                .toolbarBackground(Color.accentColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.black)
                    }
                }
                .onAppear(perform: onAppear)
                .sheet(isPresented: $showingSheet, onDismiss: setValuesFromDefault) {
                    SettingsSheet()
                }
            }
        }
    }
    
    @ViewBuilder
    private var Subtitle: some View {
        let metricID = metricOptions[currentMetricIndex]
        let currentMetricList = metricCounts[metricID, default: []]
        Button {
            currentMetricIndex = (currentMetricIndex + 1) % metricOptions.count
            loadMetrics(for: metricOptions[currentMetricIndex])
        } label: {
            VStack(alignment: .center) {
                let metricStringOpt = formattedValue(
                    Double(metricTotals[metricID, default: 0]),
                    typeIdentifier: metricID
                )
                if let metricString = metricStringOpt {
                    Text(metricString)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                    if !currentMetricList.isEmpty {
                        let lastHourMetricStringOpt = formattedValue(
                            Double(
                                currentMetricList[currentMetricList.count  - 1].metric
                            ),
                            typeIdentifier: metricID
                        )
                        if let lastHourMetricString = lastHourMetricStringOpt {
                            Text("\(lastHourMetricString) this hour")
                                .multilineTextAlignment(.center)
                                .font(.title2)
                        }
                    }
                }
            }
        }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    
    func getBarGraphStyle(for entry: Double) -> some ShapeStyle {
        if currentMetricIndex == 0 {
            return Int(entry) >= stepGoal ? Color.green : Color.red
        } else {
            let metricList = metricCounts[metricOptions[currentMetricIndex], default: []]
            let min = metricList.min { a, b in
                a.metric < b.metric
            }?.metric ?? 0
            let max = metricList.max { a, b in
                a.metric < b.metric
            }?.metric ?? 0.5
            print(min)
            print(max)
            let gap = 1 / 3 * (max - min)
            let lowerBound = min + gap
            let upperBound = max - gap

            if entry < lowerBound {
                return Color.red
            } else if entry < upperBound {
                return Color.orange
            } else {
                return Color.green
            }
        }
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

    func setValuesFromDefault() {
        let stepGoalDefault = userDefaults.integer(forKey: STEP_GOAL_KEY)
        if stepGoalDefault == 0 {
            stepGoal = 1000
            userDefaults.set(1000, forKey: STEP_GOAL_KEY)
        }
    }

    func onAppear() {
        loadMetrics(for: metricOptions[currentMetricIndex])
        setValuesFromDefault()
    }

    func loadMetrics(for indentifier: HKQuantityTypeIdentifier) {
        if metricTotals[indentifier, default: 0].isZero {
            let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            HealthData.getHourlyMetricCount(for: indentifier) { result in
                metricCounts[indentifier] = result
                metricTotals[indentifier] = result.reduce(0.0) { acc, item in
                    let testComponents = Calendar.current.dateComponents([.day, .month, .year], from: item.endDate)
                    if testComponents.day! == components.day! &&
                        testComponents.month! == components.month! &&
                        testComponents.year! == components.year! {
                        return acc + item.metric
                    } else {
                        return acc
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
