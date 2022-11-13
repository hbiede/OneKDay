//
//  AppIcon.swift
//  OneKDay
//
//  Created by Hundter Biede on 11/10/22.
//

import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case black = "Black"
    case green = "Green"
    case grey = "Grey"
    case orange = "Orange"
    case pink = "Pink"
    case primary = "Original"
    case purple = "Purple"
    case red = "Red"
    case white = "White"

    case invertedBlue = "Inverted-Blue"
    case invertedBlueDark = "Inverted-Blue-Dark"
    case invertedGreen = "Inverted-Green"
    case invertedGreenDark = "Inverted-Green-Dark"
    case invertedOrange = "Inverted-Orange"
    case invertedOrangeDark = "Inverted-Orange-Dark"
    case invertedPink = "Inverted-Pink"
    case invertedPinkDark = "Inverted-Pink-Dark"
    case invertedPurple = "Inverted-Purple"
    case invertedPurpleDark = "Inverted-Purple-Dark"
    case invertedRed = "Inverted-Red"
    case invertedRedDark = "Inverted-Red-Dark"

    case candy = "Candy"
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
        case .invertedBlue:
            return "Inverted Blue"
        case .invertedBlueDark:
            return "Inverted Blue (Dark)"
        case .invertedGreen:
            return "Inverted Green"
        case .invertedGreenDark:
            return "Inverted Green (Dark)"
        case .invertedOrange:
            return "Inverted Orange"
        case .invertedOrangeDark:
            return "Inverted Orange (Dark)"
        case .invertedPink:
            return "Inverted Pink"
        case .invertedPinkDark:
            return "Inverted Pink (Dark)"
        case .invertedPurple:
            return "Inverted Purple"
        case .invertedPurpleDark:
            return "Inverted Purple (Dark)"
        case .invertedRed:
            return "Inverted Red"
        case .invertedRedDark:
            return "Inverted Red (Dark)"
        default:
            return rawValue
        }
    }

    var preview: UIImage {
        UIImage(named: "\(rawValue)-Preview") ?? UIImage()
    }
}

let appIconSections: [String: [AppIcon]] = [
    "Color": [
        .black,
        .green,
        .grey,
        .orange,
        .pink,
        .primary,
        .purple,
        .red,
        .white
    ],
    "Inverted": [
        .invertedGreen,
        .invertedGreenDark,
        .invertedOrange,
        .invertedOrangeDark,
        .invertedPink,
        .invertedPinkDark,
        .invertedPurple,
        .invertedPurpleDark,
        .invertedRed,
        .invertedRedDark
    ],
    "Stripes": [
        .candy,
        .excite,
        .fluid,
        .friendly,
        .lovely,
        .mellow,
        .newton,
        .pastel,
        .relax,
        .spectrum,
        .three,
        .together,
        .warmth
    ]
]
