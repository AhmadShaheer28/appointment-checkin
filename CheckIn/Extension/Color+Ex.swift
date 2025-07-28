//
//  Color+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import SwiftUI


extension UIColor {
    func toHex() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return ""
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components.count >= 4 ? components[3] : 1.0
        
        return String(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(red) * 255), lroundf(Float(green) * 255), lroundf(Float(blue) * 255), lroundf(Float(alpha) * 255))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
        
        func toHex() -> String {
              if #available(iOS 14.0, *) {
                  let uiColor = UIColor(self)
                  return uiColor.toHex()
              } else {
                  return ""
              }
          }
    }

}
