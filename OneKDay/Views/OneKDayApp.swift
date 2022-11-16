//
//  OneKDayApp.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import HealthKit
import SwiftUI
import WidgetKit

@main
struct OneKDayApp: App {
    private let userDefaults = UserDefaults()
    private let notificationCenter = UNUserNotificationCenter.current()

    @State private var hasCheckedHealthAccess = false
    @State private var canReadHealthData = false

    @ViewBuilder
    var body: some Scene {
        WindowGroup {
            if canReadHealthData {
                ContentView()
            } else if hasCheckedHealthAccess {
                Text("Enable access to health data to use OneK Day")
            } else {
                VStack {}
                    .onAppear {
                        print(UIDevice.current.userInterfaceIdiom != .phone)
                        WidgetCenter.shared.reloadTimelines(ofKind: STEP_COUNT_WIDGET_KIND)
                        HealthData.requestHealthDataAccessIfNeeded { success in
                            print("didLoadHealthData: \(success)")
                            hasCheckedHealthAccess.toggle()
                            if success {
                                canReadHealthData.toggle()
                            }
                        }
                    }
            }
        }
    }
}
