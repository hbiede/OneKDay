//
//  StepCountWidget.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/9/22.
//

import Foundation
import SwiftUI
import WidgetKit

struct StepCountWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        let metrics = entry.metrics
        let lastCount = metrics.isEmpty ? 0.0 : metrics[metrics.count - 1].metric

        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .foregroundColor(.black)
                Text("\(Int(lastCount))")
                    .font(.largeTitle)
            }
            .containerBackground(Color.clear, for: .widget)
        case .accessoryRectangular, .accessoryInline:
            Text(formattedValue(
                    lastCount,
                    typeIdentifier: .stepCount
                )!
            )
            .font(.largeTitle)
            .containerBackground(Color.clear, for: .widget)
        case .systemSmall:
            SmallWidget(stepCount: metrics.isEmpty ? 0 : Int(lastCount))
                .containerBackground(Color.clear, for: .widget)
        default:
            FullWidget(metrics: metrics)
                .containerBackground(Color.clear, for: .widget)
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        StepCountWidgetEntryView(
            entry: Provider.Entry(
                date: Date(),
                configuration: Provider.Intent(),
                metrics: []
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct StepCountWidget: Widget {
    let kind: String = STEP_COUNT_WIDGET_KIND

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: Provider.Intent.self, provider: Provider()) { entry in
            StepCountWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("OneK Day")
        .description(
            NSLocalizedString(
                "widget-desc",
                comment: "The description for the widget as viewed from the widget add screen"
            )
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}
