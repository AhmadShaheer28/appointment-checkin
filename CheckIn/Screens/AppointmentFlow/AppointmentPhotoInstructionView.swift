//
//  AppointmentPhotoInstructionView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct AppointmentPhotoInstructionView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let logoSize = min(screenWidth, screenHeight) * 0.15
            let exampleImageSize = min(screenWidth, screenHeight) * 0.4
            let fontSize = screenHeight * 0.025
            let buttonFontSize = screenHeight * 0.03
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: screenHeight * 0.04) {
                    // Logo at top
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: logoSize, height: logoSize)
                        .padding(.top, screenHeight * 0.03)
                    
                    // Instruction text
                    VStack(spacing: screenHeight * 0.02) {
                        Text(String.photoInstructionTitle)
                            .font(.custom("Roboto-SemiBold", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .lineLimit(nil)
                            .padding(.horizontal, screenWidth * 0.2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(String.photoInstructionSubtitle)
                            .font(.custom("Roboto-SemiBold", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .lineLimit(nil)
                            .padding(.horizontal, screenWidth * 0.2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Example image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: exampleImageSize, height: exampleImageSize * 0.7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Example photo placeholder - we'll use a system image for now
                        Image(.holdingID)
                            .resizable()
                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.3)
                    }
                    
                    Spacer()
                    
                    // Take Photo button
                    Button(action: {
                        IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                        coordinator.push(.appointmentCamera)
                    }) {
                        Text(String.takePhoto)
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
    }
}

#Preview {
    AppointmentPhotoInstructionView()
        .environmentObject(Coordinator())
} 
