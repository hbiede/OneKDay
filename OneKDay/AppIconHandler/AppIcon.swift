//
//  AppIcon.swift
//  OneKDay
//
//  Created by Hudnter Biede on 11/10/22.
//

import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case black = "Black"
    case green = "Green"
    case grey = "Grey"
    case pink = "Pink"
    case orange = "Orange"
    case primary = "Original"
    case purple = "Purple"
    case red = "Red"
    case white = "White"

    case excite = "Excite"
    case fluid = "Fluid"
    case friendly = "Friendly"
    case lovely = "Lovely"
    case mellow = "Mellow"
    case newton = "Newton"
    case pastel = "Pastel"
    case relax = "Relax"
    case spectrum = "Spectrum"
    case three = "Three"
    case together = "Together"
    case warmth = "Warmth"

    var id: String { rawValue }
    var iconName: String? {
        switch self {
        case .primary:
            // `nil` is used to reset the app icon back to its primary icon.
            return nil
        default:
            return rawValue
        }
    }

    var description: String {
        switch self {
        case .primary:
            return "Original Blue"
        default:
            return rawValue
        }
    }

    var preview: UIImage {
        UIImage(named: "\(rawValue)-Preview") ?? UIImage()
    }
}
