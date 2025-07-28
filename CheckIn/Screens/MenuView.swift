//
//  MenuView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing based on screen dimensions
            let logoSize = min(screenWidth, screenHeight) * 0.35 // 35% of smaller dimension
            let buttonWidth = screenWidth * 0.7 // 70% of screen width
            let buttonFontSize = screenHeight * 0.03 // 3% of screen height
            let topPadding = screenHeight * 0.08 // 8% of screen height
            let buttonSpacing = screenHeight * 0.04 // 4% of screen height
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo section - fixed position
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.5)
                        .padding(.top, topPadding)
                    
                    Spacer()
                    
                    // Menu buttons
                    VStack(spacing: buttonSpacing) {
                        Button(action: {
                            coordinator.push(.appointmentTextEntry)
                        }) {
                            Text(String.appointmentCheckIn)
                                .font(.custom(FontStyle.medium.name, size: buttonFontSize))
                                .foregroundColor(.buttonTextWhite)
                                .padding(.horizontal, screenWidth * 0.08)
                                .padding(.vertical, screenHeight * 0.025)
                                .frame(maxWidth: buttonWidth)
                                .background(Color("primary_blue"))
                                .cornerRadius(screenWidth * 0.02)
                        }
                        
                        Button(action: {
                            // Handle interpreter check-in
                            // TODO: Navigate to interpreter check-in flow
                        }) {
                            Text(String.interpreterCheckIn)
                                .font(.custom(FontStyle.medium.name, size: buttonFontSize))
                                .foregroundColor(.buttonTextWhite)
                                .padding(.horizontal, screenWidth * 0.08)
                                .padding(.vertical, screenHeight * 0.025)
                                .frame(maxWidth: buttonWidth)
                                .background(Color("primary_blue"))
                                .cornerRadius(screenWidth * 0.02)
                        }
                    }
                    .padding(.bottom, screenHeight * 0.1)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
//        .gesture(
//            // Add swipe to go back gesture
//            DragGesture()
//                .onEnded { value in
//                    if value.translation.width > 100 {
//                        coordinator.popToRoot()
//                    }
//                }
//        )
    }
}

#Preview {
    MenuView()
        .environmentObject(Coordinator())
} 
