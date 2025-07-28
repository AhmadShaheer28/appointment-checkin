//
//  AppointmentPhotoVerificationView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import UIKit

struct AppointmentPhotoVerificationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var appointmentData = AppointmentDataModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let logoSize = min(screenWidth, screenHeight) * 0.15
            let photoSize = min(screenWidth, screenHeight) * 0.5
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
                    
                    // Question text
                    Text(String.photoVerificationQuestion)
                        .font(.custom("Roboto-Regular", size: fontSize))
                        .foregroundColor(Color("primary_blue"))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, screenWidth * 0.1)
                    
                    // Captured photo display
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: photoSize, height: photoSize * 0.7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if let capturedImage = appointmentData.capturedPhoto {
                            Image(uiImage: capturedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: photoSize, height: photoSize * 0.7)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            // Placeholder if no image
                            VStack(spacing: 20) {
                                Image(systemName: "photo")
                                    .font(.system(size: photoSize * 0.15))
                                    .foregroundColor(Color("primary_blue").opacity(0.7))
                                
                                Text("Photo will appear here")
                                    .font(.custom("Roboto-Regular", size: fontSize * 0.8))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: screenHeight * 0.03) {
                        // Accept Photo button
                        Button(action: {
                            // Save photo and navigate to confirmation
                            IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                            savePhotoAsPDF()
                            coordinator.push(.appointmentConfirmation)
                        }) {
                            Text(String.acceptPhoto)
                                .font(.custom("Roboto-Medium", size: buttonFontSize))
                                .foregroundColor(.white)
                                .padding(.horizontal, screenWidth * 0.1)
                                .padding(.vertical, screenHeight * 0.02)
                                .frame(maxWidth: screenWidth * 0.6)
                                .background(Color("primary_blue"))
                                .cornerRadius(12)
                        }
                        
                        // Retake Photo button
                        Button(action: {
                            // Clear image and go back to camera
                            IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                            appointmentData.capturedPhoto = nil
                            coordinator.pop()
                        }) {
                            Text(String.retakePhoto)
                                .font(.custom("Roboto-Medium", size: buttonFontSize))
                                .foregroundColor(.white)
                                .padding(.horizontal, screenWidth * 0.1)
                                .padding(.vertical, screenHeight * 0.02)
                                .frame(maxWidth: screenWidth * 0.6)
                                .background(Color("primary_blue"))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, screenHeight * 0.08)
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            // For demo purposes, create a placeholder image if none exists
            if appointmentData.capturedPhoto == nil {
                createPlaceholderImage()
            }
        }
    }
    
    private func savePhotoAsPDF() {
        guard let image = appointmentData.capturedPhoto else { return }
        
        // Create PDF document (standard letter size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.systemBlue
            ]
            "Check-In Photo Verification".draw(at: CGPoint(x: 50, y: 30), withAttributes: titleAttributes)
            
            // Names section
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let redAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.systemRed
            ]
            
            // Caregiver Name
            let caregiverNameText = "Caregiver Name: \(appointmentData.caregiverFullName)"
            let caregiverAttributedString = NSMutableAttributedString(string: caregiverNameText, attributes: nameAttributes)
            caregiverAttributedString.addAttributes(redAttributes, range: NSRange(location: 16, length: appointmentData.caregiverFullName.count))
            caregiverAttributedString.draw(at: CGPoint(x: 50, y: 70))
            
            // Claimant Name  
            let claimantNameText = "Claimant Name: \(appointmentData.childFullName)"
            let claimantAttributedString = NSMutableAttributedString(string: claimantNameText, attributes: nameAttributes)
            claimantAttributedString.addAttributes(redAttributes, range: NSRange(location: 15, length: appointmentData.childFullName.count))
            claimantAttributedString.draw(at: CGPoint(x: 50, y: 90))
            
            // Evaluation disclaimer text
            let disclaimerText = String.evaluationDisclaimer
            let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            let disclaimerRect = CGRect(x: 50, y: 120, width: 512, height: 200)
            disclaimerText.draw(in: disclaimerRect, withAttributes: disclaimerAttributes)
            
            // Signature section
            "Signature".draw(at: CGPoint(x: 50, y: 340), withAttributes: redAttributes)
            
            // Draw signature if available
            if let signatureImage = appointmentData.signatureImage {
                let signatureRect = CGRect(x: 50, y: 360, width: 200, height: 80)
                signatureImage.draw(in: signatureRect)
            }
            
            // Date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            
            let dateText = "Date: \(dateFormatter.string(from: appointmentData.checkInDate))"
            let timeText = "Time: \(timeFormatter.string(from: appointmentData.checkInDate))"
            
            dateText.draw(at: CGPoint(x: 50, y: 460), withAttributes: redAttributes)
            timeText.draw(at: CGPoint(x: 50, y: 480), withAttributes: redAttributes)
            
            // Draw the captured photo
            let imageRect = CGRect(x: 50, y: 520, width: 200, height: 150)
            image.draw(in: imageRect)
        }
        
        // Save PDF to documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("checkin_\(appointmentData.caregiverLastName)_\(Date().timeIntervalSince1970).pdf")
            
            do {
                try pdfData.write(to: fileURL)
                print("PDF saved to: \(fileURL)")
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }
    
    private func createPlaceholderImage() {
        // Create a simple placeholder image for demo
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        let image = renderer.image { context in
            // Draw background
            UIColor.lightGray.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
            
            // Draw placeholder text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.darkGray
            ]
            
            "Sample ID Photo".draw(at: CGPoint(x: 130, y: 140), withAttributes: attributes)
        }
        
        appointmentData.capturedPhoto = image
    }
}

#Preview {
    AppointmentPhotoVerificationView()
        .environmentObject(Coordinator())
} 