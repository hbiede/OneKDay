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
            if UIDevice.current.model.contains("iPad") {
                Text(
                    LocalizedStringResource(
                        "ipad-warning",
                        comment: "Text to prevent iPads from erroring"
                    )
                )
                    .font(.largeTitle)
            } else if canReadHealthData {
                ContentView()
            } else if hasCheckedHealthAccess {
                Text(
                    LocalizedStringResource(
                        "no-access-text",
                        comment: "Warning text for lack of health data access"
                    )
                )
            } else {
                VStack {
                    Button{
                        requestHealthAccess()
                    } label: {
                        Text(
                            LocalizedStringResource(
                                "enable-health-button-text",
                                comment: "Button to enable health data access"
                            )
                        )
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green)
                    .clipShape(Capsule())
                }
                    .onAppear {
                        requestHealthAccess()
                    }
            }
        }
    }

    @MainActor
    func requestHealthAccess() {
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
