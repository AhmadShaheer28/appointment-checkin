//
//  AuthenticationView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isAuthenticating = false
    @State private var authenticationStatus = "Initializing Google Drive..."
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let logoSize = min(screenWidth, screenHeight) * 0.2
            let titleFontSize = screenHeight * 0.04
            let statusFontSize = screenHeight * 0.025
            let buttonFontSize = screenHeight * 0.03
            
            Color("light_beige")
                .ignoresSafeArea()
            
            // Center the content both horizontally and vertically
            HStack {
                Spacer()
                
                VStack(spacing: screenHeight * 0.05) {
                    Spacer()
                    
                    // Logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                    
                    // Title
                    Text("Setting Up CheckIn App")
                        .font(.custom("Roboto-Bold", size: titleFontSize))
                        .foregroundColor(Color("primary_blue"))
                        .multilineTextAlignment(.center)
                    
                    // Status message
                    VStack(spacing: screenHeight * 0.02) {
                        if isAuthenticating {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("primary_blue")))
                        }
                        
                        Text(authenticationStatus)
                            .font(.custom("Roboto-Regular", size: statusFontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, screenWidth * 0.05)
                    }
                    
                    // Error message and retry button
                    if showError {
                        VStack(spacing: screenHeight * 0.02) {
                            Text(errorMessage)
                                .font(.custom("Roboto-Regular", size: statusFontSize * 0.9))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, screenWidth * 0.05)
                            
                            Button(action: {
                                Task { @MainActor in
                                    await performAuthentication()
                                }
                            }) {
                                Text("Retry Authentication")
                                    .font(.custom("Roboto-Medium", size: buttonFontSize))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, screenWidth * 0.08)
                                    .padding(.vertical, screenHeight * 0.02)
                                    .background(Color("primary_blue"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer()
                    
//                     Skip button (for testing/development)
                    Button(action: {
                        proceedToApp()
                    }) {
                        Text("Skip (Development Mode)")
                            .font(.custom("Roboto-Regular", size: statusFontSize * 0.8))
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .padding(.bottom, screenHeight * 0.05)
                }
                .frame(maxWidth: screenWidth * 0.6) // Limit width for better centering
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .onAppear {
            authenticateGoogleDrive()
        }
    }
    
    private func authenticateGoogleDrive() {
        // Check if already authenticated on main thread
        Task { @MainActor in
            if GoogleDriveManager.shared.isAlreadyAuthenticated() {
                authenticationStatus = "✅ Google Drive already connected!"
                // Brief delay to show success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    proceedToApp()
                }
                return
            }
            
            // If not authenticated, start the authentication process
            await performAuthentication()
        }
    }
    
    @MainActor
    private func performAuthentication() async {
        isAuthenticating = true
        showError = false
        authenticationStatus = "Connecting to Google Drive..."
        
        do {
            try await GoogleDriveManager.shared.authenticate()
            
            authenticationStatus = "✅ Google Drive connected successfully!"
            isAuthenticating = false
            
            // Brief delay to show success message
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            proceedToApp()
            
        } catch {
            isAuthenticating = false
            showError = true
            authenticationStatus = "❌ Authentication failed"
            
            // Handle different error types
            if error.localizedDescription.contains("cancelled") {
                errorMessage = "Authentication was cancelled. Please try again."
            } else if error.localizedDescription.contains("no view controller") {
                errorMessage = "Unable to present authentication screen"
            } else if error.localizedDescription.contains("authentication failed") {
                errorMessage = "Failed to authenticate with Google Drive"
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
    }
    
    private func proceedToApp() {
        coordinator.push(.homeRotation)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(Coordinator())
} 
