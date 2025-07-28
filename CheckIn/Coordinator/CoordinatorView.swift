//
//  CoordinatorView.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .homeRotation)
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
        }
        .environmentObject(coordinator)
        .onAppear {
            // Set coordinator reference for idle timer
            IdleTimerManager.shared.setCoordinator(coordinator)
        }
    }
}

#Preview {
    CoordinatorView()
}
