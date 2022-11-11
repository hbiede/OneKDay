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
            Text(formattedValue(
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
                        .frame(maxWidth: 48)
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
