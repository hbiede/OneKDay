//
//  ChangeIconViewModal.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/11/22.
//
//  Adapted from https://www.avanderlee.com/swift/alternate-app-icon-configuration-in-xcode/
//

import Foundation
import UIKit

final class ChangeAppIconViewModel: ObservableObject {

    @Published private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName,
           let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            #if DEBUG
            selectedAppIcon = .relax
            #else
            selectedAppIcon = .primary
            #endif
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                /// No need to update since we're already using this icon.
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                /// We're only logging the error here and not actively handling the app icon failure
                /// since it's very unlikely to fail.
                print("Updating icon to \(String(describing: icon.iconName)) failed.")

                /// Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}
