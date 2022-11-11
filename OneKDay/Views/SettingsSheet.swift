//
//  SettingsSheet.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/8/22.
//

import Foundation
import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = ChangeAppIconViewModel()

    @State private var stepGoal = "0"
    @State private var minutesEarly = "0"

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Step Goal/Hour")
                        Spacer()
                        TextField("", text: $stepGoal)
                            .multilineTextAlignment(.trailing)
                            .onSubmit(submitStepGoal)
                            .onDisappear(perform: submitStepGoal)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Metrics")
                }

                Section {
                    ForEach(AppIcon.allCases) { icon in
                        HStack {
                            Image(uiImage: icon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            Text(icon.description)
                            if viewModel.selectedAppIcon == icon {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.headline)
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                viewModel.updateAppIcon(to: icon)
                            }
                        }
                    }
                } header: {
                    Text("App Icon")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.backward")
                    }
                }
            }
            .toolbarRole(.navigationStack)
        }
        .onAppear {
            let stepGoalDefault = UserDefaults().integer(forKey: STEP_GOAL_KEY)
            stepGoal = "\(stepGoalDefault == 0 ? 1000 : stepGoalDefault)"
        }
    }

    func onDismiss() {
        submitStepGoal()
        dismiss()
    }

    func submitStepGoal() {
        UserDefaults().set(Int(stepGoal), forKey: STEP_GOAL_KEY)
        print("New Goal: \(stepGoal)")
    }
}
