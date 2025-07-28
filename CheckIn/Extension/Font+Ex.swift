//
//  Font+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import SwiftUI


extension Font {
    // Large headings
    static let h1 = custom(FontStyle.semibold.name, fixedSize: 108)
    static let h2 = custom(FontStyle.semibold.name, fixedSize: 70)
    
    // Display titles
    static let d1 = custom(FontStyle.medium.name, fixedSize: 43)
    static let d2 = custom(FontStyle.medium.name, fixedSize: 40)
    static let d3 = custom(FontStyle.medium.name, fixedSize: 39)
    
    // iPad optimized fonts
    static let slideTitleiPad = custom(FontStyle.semibold.name, fixedSize: 72)
    static let buttonLargeiPad = custom(FontStyle.medium.name, fixedSize: 36)
    static let buttonTextiPad = custom(FontStyle.medium.name, fixedSize: 28)
    static let aTeamLabeliPad = custom(FontStyle.bold.name, fixedSize: 48)
    
    // App specific fonts (kept for compatibility)
    static let slideTitle = custom(FontStyle.semibold.name, fixedSize: 48)
    static let buttonLarge = custom(FontStyle.medium.name, fixedSize: 24)
    static let buttonText = custom(FontStyle.medium.name, fixedSize: 20)
    static let aTeamLabel = custom(FontStyle.bold.name, fixedSize: 32)
}
