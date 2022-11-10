//
//  WidgetProvider.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/9/22.
//

import Intents
import WidgetKit

struct Provider: IntentTimelineProvider {
    
    typealias Entry = StepCountEntry
    
    typealias Intent = StepCountConfigurationIntent
    
    let stepGoal = UserDefaults().integer(forKey: STEP_GOAL_KEY)

    func placeholder(in context: Context) -> StepCountEntry {
        print(stepGoal)
        return Entry(date: Date(), configuration: Intent(), metrics: [])
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> ()) {
        print(stepGoal)
        getStepCounts { metrics in
            completion(
                Entry(date: Date(), configuration: configuration, metrics: metrics)
            )
        }
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print(stepGoal)
        getStepCounts { metrics in
            completion(
                Timeline(
                    entries: [
                        Entry(date: Date(), configuration: configuration, metrics: metrics)
                    ],
                    // Clear every 10 minutes
                    policy: .after(Date(timeIntervalSinceNow: 600))
                )
            )
        }
    }
    
    func getStepCounts(completion: @escaping ([MetricEntry]) -> Void) {
        HealthData.getHourlyMetricCount(for: .stepCount, completion: completion)
    }
}

struct StepCountEntry: TimelineEntry {
    let date: Date
    let configuration: Provider.Intent
    let metrics: [MetricEntry]
}
