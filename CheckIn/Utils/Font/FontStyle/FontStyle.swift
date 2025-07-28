//
//  File.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation


enum FontStyle {
    case regular
    case medium
    case semibold
    case bold
    case extraBold
    
    
    var name: String {
        switch self {
            
        case .regular:
            return "Roboto-Regular"
        case .medium:
            return "Roboto-Medium"
        case .semibold:
            return "Roboto-SemiBold"
        case .bold:
            return "Roboto-Bold"
        case .extraBold:
            return "Roboto-ExtraBold"
        }
    }
}
