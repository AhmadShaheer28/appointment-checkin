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
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                        .padding(.top, screenHeight * 0.05)
                    
                    Spacer()
                    
                    // Instruction text
                    VStack(spacing: screenHeight * 0.02) {
                        Text(String.photoInstructionTitle)
                            .font(.custom("Roboto-Regular", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, screenWidth * 0.1)
                        
                        Text("Make sure your face and your ID can both be seen as in the picture below.")
                            .font(.custom("Roboto-Regular", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, screenWidth * 0.1)
                            .fontWeight(.semibold)
                        
                        Text(String.photoInstructionSubtitle)
                            .font(.custom("Roboto-Regular", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, screenWidth * 0.1)
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
                        VStack(spacing: 20) {
                            Image(systemName: "person.and.background.dotted")
                                .font(.system(size: exampleImageSize * 0.15))
                                .foregroundColor(Color("primary_blue").opacity(0.7))
                            
                            Text("Example: Person holding ID")
                                .font(.custom("Roboto-Regular", size: fontSize * 0.8))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Take Photo button
                    Button(action: {
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
    }
}

#Preview {
    AppointmentPhotoInstructionView()
        .environmentObject(Coordinator())
} 