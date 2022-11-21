//
//  SettingsSheet.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Foundation
import SwiftUI

struct SettingsSheet: View {
    let userDefaults = UserDefaults()

    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = ChangeAppIconViewModel()

    @State private var stepGoal = NumberFormatter().string(from: 0)!

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text(
                            NSLocalizedString(
                                "step-goal-setting-title",
                                comment: "Setting title for the goal step count per hour"
                            )
                        )
                        Spacer()
                        TextField("", text: $stepGoal)
                            .multilineTextAlignment(.trailing)
                            .onSubmit(submitStepGoal)
                            .onDisappear(perform: submitStepGoal)
                            .keyboardType(.numberPad)
                    }
                }

                Section {
                    NavigationLink(
                        destination: AppIconSelector().environmentObject(viewModel)
                    ) {
                        HStack {
                            Image(uiImage: viewModel.selectedAppIcon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                            Text(
                                NSLocalizedString(
                                    "app-icon-setting-title",
                                    comment: "App Icon setting title"
                                )
                            )
                        }
                    }
                }
            }
            .navigationTitle(
                NSLocalizedString(
                    "settings-modal-title",
                    comment: "The header for the settings modal"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Label(
                            NSLocalizedString(
                                "back-button-label",
                                comment: "Label for the back button"
                            ),
                            systemImage: "chevron.backward"
                        )
                    }
                }
            }
            .toolbarRole(.navigationStack)
        }
        .onAppear {
            let stepGoalDefault = userDefaults.integer(forKey: STEP_GOAL_KEY)
            stepGoal = "\(stepGoalDefault == 0 ? 1000 : stepGoalDefault)"
        }
    }

    func onDismiss() {
        submitStepGoal()
        dismiss()
    }

    func submitStepGoal() {
        let stepGoalNumber = Int(stepGoal)
        if stepGoalNumber != userDefaults.integer(forKey: STEP_GOAL_KEY) {
            userDefaults.set(stepGoalNumber, forKey: STEP_GOAL_KEY)
            print("New Goal: \(String(describing: stepGoalNumber))")
        }
    }
}
