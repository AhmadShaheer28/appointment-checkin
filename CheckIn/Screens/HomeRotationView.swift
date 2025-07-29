//
//  HomeRotationView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct HomeRotationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var currentSlideIndex = 0
    @State private var timer: Timer?
    
    private let slides: [SlideData] = [
        SlideData(title: .interpreter, buttonText: .checkInHere),
        SlideData(title: .evaluationAppointment, buttonText: .checkInHere),
        SlideData(title: .evaluationAppointment, buttonText: .checkInHere),
        SlideData(title: .interpreter, buttonText: .checkInHere)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing based on screen dimensions
            let titleFontSize = screenHeight * 0.06 // 6% of screen height
            let buttonWidth = screenWidth * 0.6 // 60% of screen width
            let buttonFontSize = screenHeight * 0.025 // 2.5% of screen height
            let topPadding = screenHeight * 0.04 // 8% of screen height
            let titleHeight = screenHeight * 0.15 // Fixed height for title area
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Fixed height title area to prevent logo movement
                    VStack {
                        Spacer()
                        Text(slides[currentSlideIndex].title)
                            .font(.custom(FontStyle.semibold.name, size: titleFontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, screenWidth * 0.05)
                            .id(currentSlideIndex) // Key for transition
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    .frame(height: titleHeight)
                    .padding(.top, topPadding)
                    
                    Spacer()
                    
                    // Centered logo section - fixed position
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.5)
                        .id("button-\(currentSlideIndex)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    Spacer()
                    
                    // Check-in button with sliding animation
                    Button(action: {
                        stopTimer()
                        IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                        coordinator.push(.menu)
                    }) {
                        Text(slides[currentSlideIndex].buttonText)
                            .font(.custom(FontStyle.medium.name, size: buttonFontSize))
                            .foregroundColor(.buttonTextWhite)
                            .padding(.horizontal, screenWidth * 0.08)
                            .padding(.vertical, screenHeight * 0.02)
                            .frame(maxWidth: buttonWidth)
                            .background(Color("primary_blue"))
                            .cornerRadius(screenWidth * 0.02)
                    }
                    .id("button-\(currentSlideIndex)") // Key for transition
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .disabled(true)
                    .padding(.bottom, screenHeight * 0.08)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onTapGesture {
            stopTimer()
            IdleTimerManager.shared.userDidInteract() // Reset idle timer on tap
            coordinator.push(.menu)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentSlideIndex = (currentSlideIndex + 1) % slides.count
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct SlideData {
    let title: String
    let buttonText: String
}

#Preview {
    HomeRotationView()
        .environmentObject(Coordinator())
} 
