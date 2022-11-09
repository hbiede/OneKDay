//
//  ContentView.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Charts
import HealthKit
import SwiftUI

struct StepCountEntry {
    var category: Date
    
    var value: Int
}

struct ContentView: View {
    private let userDefaults = UserDefaults()

    @State private var stepCounts: [StepCountEntry] = []
    @State private var stepCountTotal: Int = 0
    @State private var showingSheet = false
    @AppStorage(STEP_GOAL_KEY) var stepGoal = 0
    
    @ViewBuilder
    var body: some View {
        if !HKHealthStore.isHealthDataAvailable() {
            Text("Enable access to step count")
        } else {
            NavigationView {
                VStack {
                    if !stepCounts.isEmpty {
                        Chart(stepCounts, id: \.category) {
                            BarMark(
                                x: .value("Time", $0.category, unit: .hour),
                                y: .value("Steps", $0.value)
                            )
                                .foregroundStyle($0.value >= stepGoal ? Color.green : Color.red)
                                .accessibilityLabel(formatDate($0.category))
                                .accessibilityValue("\($0.value) Steps")
                            RuleMark(
                                y: .value("Goal", stepGoal)
                            )
                                .accessibilityLabel("Goal")
                                .accessibilityValue("\(stepGoal) Steps")
                        }
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                    VStack(alignment: .center) {
                        Text("\(stepCountTotal) steps today")
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                        if !stepCounts.isEmpty {
                            Text(
                                "\(stepCounts[stepCounts.count  - 1].value) this hour"
                            )
                                .multilineTextAlignment(.center)
                                .font(.title2)
                        }
                    }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
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
        let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        HealthData.getHourlyStepCount { result in
            stepCounts = result.map { entry in
                StepCountEntry(category: entry.startDate, value: Int(entry.stepCount))
            }
            stepCountTotal = result.reduce(0) { acc, item in
                let testComponents = Calendar.current.dateComponents([.day, .month, .year], from: item.endDate)
                if testComponents.day! == components.day! &&
                    testComponents.month! == components.month! &&
                    testComponents.year! == components.year!
                {
                    return acc + Int(item.stepCount)
                } else {
                    return acc
                }
            }
        }
        setValuesFromDefault()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
