//
//  IdleTimerManager.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import Combine

class IdleTimerManager: ObservableObject {
    static let shared = IdleTimerManager()
    
    private var idleTimer: Timer?
    private let idleTimeInterval: TimeInterval = 180 // 3 minutes
    @Published var coordinator: Coordinator?
    
    private init() {}
    
    func setCoordinator(_ coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    // Start or restart the idle timer
    func resetIdleTimer() {
        stopIdleTimer()
        startIdleTimer()
    }
    
    // Stop the idle timer
    func stopIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
    }
    
    // Start the idle timer
    private func startIdleTimer() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeInterval, repeats: false) { [weak self] _ in
            self?.handleIdleTimeout()
        }
    }
    
    // Handle when idle timeout occurs
    private func handleIdleTimeout() {
        DispatchQueue.main.async { [weak self] in
            // Clear all data models
            AppointmentDataModel.shared.clearData()
            InterpreterDataModel.shared.clearData()
            
            // Navigate back to home rotation
            self?.coordinator?.popToRoot()
            
            // Stop the timer
            self?.stopIdleTimer()
            
            print("Idle timeout: Returned to home screen and cleared all data")
        }
    }
    
    // Call this method on any user interaction
    func userDidInteract() {
        resetIdleTimer()
    }
    
    // Pause idle timer (for specific scenarios like camera usage)
    func pauseIdleTimer() {
        stopIdleTimer()
    }
    
    // Resume idle timer
    func resumeIdleTimer() {
        resetIdleTimer()
    }
} 