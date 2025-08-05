//
//  AppointmentConfirmationView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct AppointmentConfirmationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var appointmentData = AppointmentDataModel.shared
    @State private var autoReturnTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let logoSize = min(screenWidth, screenHeight) * 0.15
            let fontSize = screenHeight * 0.025
            let buttonFontSize = screenHeight * 0.03
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: screenHeight * 0.08) {
                    // Logo at top
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                        .padding(.top, screenHeight * 0.05)
                    
                    Spacer()
                    
                    // Thank you message
                    Text(String.thankYouMessage)
                        .font(.custom("Roboto-Regular", size: fontSize))
                        .foregroundColor(Color("primary_blue"))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, screenWidth * 0.1)
                    
                    Spacer()
                    
                    // Finish Check-In button
                    Button(action: {
                        IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                        finishCheckIn()
                    }) {
                        Text(String.finishCheckIn)
                            .font(.custom("Roboto-Medium", size: buttonFontSize))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenWidth * 0.1)
                            .padding(.vertical, screenHeight * 0.02)
                            .frame(maxWidth: screenWidth * 0.6)
                            .background(Color("primary_blue"))
                            .cornerRadius(12)
                    }
                    .padding(.bottom, screenHeight * 0.08)
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            startAutoReturnTimer()
        }
        .onDisappear {
            cancelAutoReturnTimer()
        }
    }
    
    private func startAutoReturnTimer() {
        // Auto-return to home screen after 30 seconds
        autoReturnTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
            finishCheckIn()
        }
    }
    
    private func cancelAutoReturnTimer() {
        autoReturnTimer?.invalidate()
        autoReturnTimer = nil
    }
    
    private func finishCheckIn() {
        cancelAutoReturnTimer()
        
        // Clear all appointment data
        appointmentData.clearData()
        
        // Return to the rotating home screen
        coordinator.popToRoot()
    }
}

#Preview {
    AppointmentConfirmationView()
        .environmentObject(Coordinator())
} 
