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
    @Environment(\.scenePhase) var scenePhase

    private let userDefaults = UserDefaults()

    @State private var currentMetricIndex: Int = 0
    @State private var metricTotals: [HKQuantityTypeIdentifier: Double] = [metricOptions[0]: 0.0]
    @State private var metricCounts: [HKQuantityTypeIdentifier: [MetricEntry]] = [
        metricOptions[0]: []
    ]
    @State private var showingSheet = false
    @State private var dataAnimationPower = 0.0

    @AppStorage(STEP_GOAL_KEY) var stepGoal = 0

    @ViewBuilder
    var body: some View {
        let metricID = metricOptions[currentMetricIndex]
        let currentMetricList = metricCounts[metricID, default: []]
        if !HKHealthStore.isHealthDataAvailable() {
            Text(
                NSLocalizedString(
                    "no-health-access",
                    comment: "Text for when the app does not have access to health data"
                )
            )
        } else {
            NavigationView {
                VStack {
                    if !currentMetricList.isEmpty {
                        Chart(currentMetricList, id: \.startDate) {
                            BarMark(
                                x: .value(
                                    NSLocalizedString(
                                        "time-value-label",
                                        comment: "The lael for the time axis of the graph"
                                    ),
                                    $0.startDate,
                                    unit: .hour,
                                    calendar: Calendar.current
                                ),
                                y: .value(
                                    getUnitSuffix(
                                        for: preferredUnit(
                                            for: metricID
                                        ),
                                        with: $0.metric
                                    )?.capitalized(with: Locale.current) ??
                                    NSLocalizedString(
                                        "unknown-measurement-unit",
                                        comment: "Default measurement unit if the real one is unknown"
                                    ),
                                    max(pow($0.metric, dataAnimationPower), 0)
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
                                    y: .value(
                                            NSLocalizedString(
                                                "goal-a11y-label",
                                                comment: "A11y label for the goal line"
                                            ),
                                            stepGoal
                                    )
                                )
                                .accessibilityLabel(
                                    NSLocalizedString(
                                        "goal-a11y-label",
                                        comment: "A11y label for the goal line"
                                    )
                                )
                                .accessibilityValue(formattedValue(
                                    Double(stepGoal),
                                    typeIdentifier: metricID
                                ) ?? "X")
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                        subtitle
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                .navigationTitle("OneK Day")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.black)
                    }
                }
                .toolbarBackground(Color.accentColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .onAppear(perform: onAppear)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        loadMetrics(for: metricOptions[currentMetricIndex])
                    }
                }
                .sheet(isPresented: $showingSheet, onDismiss: setValuesFromDefault) {
                    SettingsSheet()
                }
            }
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        let metricID = metricOptions[currentMetricIndex]
        let currentMetricList = metricCounts[metricID, default: []]
        Button {
            currentMetricIndex = (currentMetricIndex + 1) % metricOptions.count
            loadMetrics(for: metricOptions[currentMetricIndex])
            animateData()
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
                            Text(
                                String.localizedStringWithFormat(
                                    NSLocalizedString(
                                        "this-hour-subtitle",
                                        comment: "Subtitle explaining the metric count achieved this hour   (e.g., '1234 steps this hour')"
                                    ),
                                    lastHourMetricString
                                )
                            )
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
            return getGoalComparisonColor(Int(entry), goal: stepGoal)
        } else {
            let metricList = metricCounts[metricOptions[currentMetricIndex], default: []]
            let minMetric = metricList.min(by: <)?.metric ?? 0
            let maxMetric = metricList.max(by: <)?.metric ?? 0.5
            let sectionSize = 1 / 3 * (maxMetric - minMetric)
            let lowerBound = minMetric + sectionSize
            let upperBound = maxMetric - sectionSize

            if entry < lowerBound {
                return Color.red
            } else if entry < upperBound {
                return Color.orange
            } else {
                return Color.green
            }
        }
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

    func animateData() {
        dataAnimationPower = 10
        withAnimation(.linear(duration: 0.5)) {
            dataAnimationPower = 1
        }
    }

    func loadMetrics(for identifier: HKQuantityTypeIdentifier) {
        #if DEBUG
        let components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: Date(timeIntervalSinceNow: 3600))
        var result: [MetricEntry] = []
        for i in (1...24).reversed() {
            let startDate = Date(timeInterval: -3600 * Double(i), since: Calendar.current.date(from: components)!)
            let testComponents = Calendar.current.dateComponents([.hour], from: startDate)
            print(testComponents.hour!)
            var stepCount = Double.random(in: 800...1500)
            if testComponents.hour! == 7 || testComponents.hour! == 21 || testComponents.hour! == 22 {
                stepCount = Double.random(in: 200...500)
            } else if testComponents.hour! < 7 || testComponents.hour! > 22 {
                stepCount = Double.random(in: 0...50)
            }
            result.append(
                MetricEntry(
                    metric: stepCount,
                    startDate: startDate,
                    endDate: Date(timeIntervalSinceNow: -3600 * (Double(i) + 1)),
                    type: identifier
                )
            )
        }
        metricCounts[identifier] = result
        metricTotals[identifier] = result.reduce(0.0) { acc, item in
            let testComponents = Calendar.current.dateComponents([.day, .month, .year], from: item.endDate)
            if testComponents.day! == components.day! &&
                testComponents.month! == components.month! &&
                testComponents.year! == components.year! {
                return acc + item.metric
            } else {
                return acc
            }
        }
        animateData()
        #else
        if metricTotals[identifier, default: 0].isZero {
            let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            HealthData.getHourlyMetricCount(for: identifier) { result in
                metricCounts[identifier] = result
                metricTotals[identifier] = result.reduce(0.0) { acc, item in
                    let testComponents = Calendar.current.dateComponents([.day, .month, .year], from: item.endDate)
                    if testComponents.day! == components.day! &&
                        testComponents.month! == components.month! &&
                        testComponents.year! == components.year! {
                        return acc + item.metric
                    } else {
                        return acc
                    }
                }
                animateData()
            }
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
