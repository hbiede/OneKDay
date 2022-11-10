//
//  OneKDayApp.swift
//  OneKDay
//
//  Created by Elijah Biede on 11/8/22.
//

import BackgroundTasks
import HealthKit
import UserNotifications
import SwiftUI

@main
struct OneKDayApp: App {
    private let userDefaults = UserDefaults()
    private let notificationCenter = UNUserNotificationCenter.current()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    notificationCenter.requestAuthorization(options: [.alert, .provisional, .sound]) { granted, _ in
                        if granted {
                            print("User allowed alerts")
                        } else {
                            print("User denied alerts")
                        }
                    }
                    BGTaskScheduler.shared.register(forTaskWithIdentifier: BACKGROUND_ID, using: .main) { task in
                        // swiftlint:disable:next force_cast
                        handleBackgroundUpdate(task: task as! BGAppRefreshTask)
                    }
                    requestAppRefresh()
                    HealthData.requestHealthDataAccessIfNeeded { success in
                        print("didLoadHealthData: \(success)")
                    }
                    let content = UNMutableNotificationContent()
                    content.title = "Get Stepping!"
                    content.body = "Get your \(1000) steps in the next \(15) minutes!"
                    let request = UNNotificationRequest(
                        identifier: "stepGoalNotAchieved",
                        content: content,
                        trigger: nil
                    )
                    notificationCenter.add(request)
                }
        }
    }

    func handleBackgroundUpdate(task: BGAppRefreshTask) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let contentTest = UNMutableNotificationContent()
        contentTest.title = "TEST: Get Stepping!"
        contentTest.body = "Get your \(1000) steps in the next \(components.hour!) minutes!"
        let request1 = UNNotificationRequest(identifier: "testNotifSteps", content: contentTest, trigger: nil)
        notificationCenter.add(request1)

        // Only run from 8 AM to 8 PM
        if components.hour! >= 8 && components.hour! < 20 {
            HealthData.getHourlyMetricCount(for: .stepCount) { result in
                let stepGoal = userDefaults.integer(forKey: STEP_GOAL_KEY)

                let minutesEarly = 60 - components.minute!
                if result.isEmpty || (Int(result[0].metric) < minutesEarly && Int(result[0].metric) > 0) {
                    let content = UNMutableNotificationContent()
                    content.title = "Get Stepping!"
                    content.body = "Get your \(stepGoal) steps in the next \(minutesEarly) minutes!"
                    let request = UNNotificationRequest(
                        identifier: "stepGoalNotAchieved",
                        content: content,
                        trigger: nil
                    )
                    notificationCenter.add(request)
                }
            }
        }
        requestAppRefresh()
    }

    func requestAppRefresh() {
        let components = Calendar.current.dateComponents([.hour], from: Date())
        let request = BGAppRefreshTaskRequest(identifier: BACKGROUND_ID)
        request.earliestBeginDate = Date(
            // 15 minutes in the future, unless it's between 8 PM or before 8 AM, in which case 60 minutes
            timeIntervalSinceNow: components.hour! >= 8 && components.hour! < 20 ? 900 : 3600
        )
        do {
           try BGTaskScheduler.shared.submit(request)
        } catch {
           print("Could not schedule app refresh: \(error)")
        }
    }
}
