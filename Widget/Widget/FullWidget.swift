//
//  FullWidget.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/9/22.
//

import Charts
import Foundation
import SwiftUI
import WidgetKit

struct FullWidget: View {
    @State var metrics: [MetricEntry] = []

    var body: some View {
        if metrics.isEmpty {
            Text(
                formattedValue(
                    0,
                    typeIdentifier: .stepCount
                )!
            )
            .font(.largeTitle)
        } else {
            HStack {
                ZStack(alignment: .center) {
                    Circle()
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: 56)
                    Text("\(Int(metrics[metrics.count - 1].metric))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                Chart(metrics, id: \.startDate) {
                    BarMark(
                        x: .value("Time", $0.startDate, unit: .hour),
                        y: .value("Steps", $0.metric)
                    )
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel(formatDate($0.startDate))
                    .accessibilityValue(formattedValue(
                        $0.metric,
                        typeIdentifier: .stepCount
                    ) ?? "X")
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            }
        }
    }
}

#if DEBUG
struct FullWidget_Previews: PreviewProvider {
    static var previews: some View {
        FullWidget(metrics: generateData())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }

    static func generateData() -> [MetricEntry] {
        let components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: Date(timeIntervalSinceNow: 3600))
        var result: [MetricEntry] = []
        for i in (1...24).reversed() {
            let startDate = Date(timeInterval: -3600 * Double(i), since: Calendar.current.date(from: components)!)
            let testComponents = Calendar.current.dateComponents([.hour], from: startDate)
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
                    type: .stepCount
                )
            )
        }
        return result
    }
}
#endif
