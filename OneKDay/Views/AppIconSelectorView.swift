//
//  AppIconSelectorView.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/11/22.
//

import Foundation
import SwiftUI

struct AppIconSelector: View {
    @EnvironmentObject var viewModel: ChangeAppIconViewModel

    var body: some View {
        Form {
            ForEach(Array(appIconSections.keys), id: \.self) { key in
                Section {
                    ForEach(appIconSections[key]!, id: \.rawValue) { icon in
                        HStack {
                            Image(uiImage: icon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            Text(icon.description)

                            Spacer()
                            Image(systemName: viewModel.selectedAppIcon == icon
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundColor(
                                viewModel.selectedAppIcon == icon ? .green : .gray
                            )
                            .font(.headline)
                        }
                        // Needed to allow for tapping on a spacer
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                viewModel.updateAppIcon(to: icon)
                            }
                        }
                    }
                } header: {
                    Text(key)
                }
            }
        }
    }

    func onTap(icon: AppIcon) {
        withAnimation(.easeInOut(duration: 0.1)) {
            viewModel.updateAppIcon(to: icon)
        }
    }
}
