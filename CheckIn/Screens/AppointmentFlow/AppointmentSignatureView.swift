//
//  AppointmentSignatureView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct AppointmentSignatureView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var appointmentData = AppointmentDataModel.shared
    @State private var signaturePaths: [Path] = []
    @State private var currentPath = Path()
    @State private var isSigning = false
    @State private var hasSignature = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let logoSize = min(screenWidth, screenHeight) * 0.15
            let signatureBoxWidth = screenWidth * 0.8
            let signatureBoxHeight = screenHeight * 0.35
            let fontSize = screenHeight * 0.03
            let buttonFontSize = screenHeight * 0.03
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: screenHeight * 0.05) {
                    // Logo at top
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize, height: logoSize)
                        .padding(.top, screenHeight * 0.05)
                    
                    Spacer()
                    
                    // Please Sign Below text
                    Text(String.pleaseSignBelow)
                        .font(.custom("Roboto-Medium", size: fontSize))
                        .foregroundColor(Color("primary_blue"))
                        .multilineTextAlignment(.center)
                    
                    // Signature box
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: signatureBoxWidth, height: signatureBoxHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            )
                        
                        // Signature canvas
                        Canvas { context, size in
                            context.stroke(
                                Path { path in
                                    for signaturePath in signaturePaths {
                                        path.addPath(signaturePath)
                                    }
                                    path.addPath(currentPath)
                                },
                                with: .color(Color("primary_blue")),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                        }
                        .frame(width: signatureBoxWidth, height: signatureBoxHeight)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if !isSigning {
                                        currentPath = Path()
                                        currentPath.move(to: value.location)
                                        isSigning = true
                                    } else {
                                        currentPath.addLine(to: value.location)
                                    }
                                }
                                .onEnded { _ in
                                    signaturePaths.append(currentPath)
                                    currentPath = Path()
                                    isSigning = false
                                    hasSignature = !signaturePaths.isEmpty
                                }
                        )
                        
                        // Show message if no signature
                        if signaturePaths.isEmpty && !isSigning {
                            Text("Sign here with your finger")
                                .font(.custom("Roboto-Regular", size: fontSize * 0.7))
                                .foregroundColor(.gray)
                                .allowsHitTesting(false)
                        }
                    }
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Continue button (disabled until signed)
                    Button(action: {
                        if hasSignature {
                            IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                            saveSignatureToDataModel()
                            coordinator.push(.appointmentPhotoInstruction)
                        }
                    }) {
                        Text(String.continueButton)
                            .font(.custom("Roboto-Medium", size: buttonFontSize))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenWidth * 0.1)
                            .padding(.vertical, screenHeight * 0.02)
                            .frame(maxWidth: screenWidth * 0.6)
                            .background(hasSignature ? Color("primary_blue") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!hasSignature)
                    .padding(.bottom, screenHeight * 0.08)
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
    }
    
    private func saveSignatureToDataModel() {
        let signatureBoxWidth: CGFloat = 600
        let signatureBoxHeight: CGFloat = 300
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: signatureBoxWidth, height: signatureBoxHeight))
        
        let signatureImage = renderer.image { context in
            // Fill with white background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: signatureBoxWidth, height: signatureBoxHeight))
            
            // Draw signature paths
            context.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            for path in signaturePaths {
                context.cgContext.addPath(path.cgPath)
                context.cgContext.strokePath()
            }
        }
        
        appointmentData.signatureImage = signatureImage
    }
}

#Preview {
    AppointmentSignatureView()
        .environmentObject(Coordinator())
} 