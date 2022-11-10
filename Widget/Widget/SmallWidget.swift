//
//  SmallWidget.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/9/22.
//

import Foundation
import SwiftUI
import WidgetKit

import Foundation
import SwiftUI
import WidgetKit

struct SmallWidget: View {
    @State var stepCount: Int = 1

    @ViewBuilder
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.green)
            VStack {
                Text("")
                    .accessibilityHidden(true)
                    .font(.title3)
                Text("\(stepCount)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.system(size: 500))
                    .minimumScaleFactor(0.01)
                Text(getUnitSuffix(for: .count())!.capitalized)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
        }
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            .accessibilityLabel(formattedValue(
                    Double(stepCount),
                    typeIdentifier: .stepCount
                )!
            )
    }
}

