//
//  UIApplication-Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine

extension UIApplication {
    var appWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first(where: { $0 is UIWindowScene })
                    .flatMap({ $0 as? UIWindowScene })?.windows
                    .first(where: \.isKeyWindow)
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
}

extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
    
}
