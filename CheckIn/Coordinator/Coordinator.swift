//
//  Coordinator.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import SwiftUI


enum Page: Hashable {
    case home
}


class Coordinator: ObservableObject {
    @Published var path = [Page]()

    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop(page: Page? = nil) {
        if let page = page {
            path.removeAll { $0 == page }
            
        } else {
            if path.isNotEmpty {
                path.removeLast()
            }
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            EmptyView()
        }
        
    }
    
}
