//
//  InterpreterConfirmationView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import UIKit

struct InterpreterConfirmationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var interpreterData = InterpreterDataModel.shared
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
                    Text(String.interpreterThankYouMessage)
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
            saveInterpreterPDF()
            interpreterData.uploadToGoogleDrive() // Upload to Google Drive in background
            startAutoReturnTimer()
        }
        .onDisappear {
            cancelAutoReturnTimer()
        }
    }
    
    private func saveInterpreterPDF() {
        // Create PDF document (standard letter size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Define text attributes
            let blackAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let redAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.systemRed
            ]
            
            // Claimant Name
            let claimantNameText = "Claimant Name: \(interpreterData.childFullName)"
            let claimantAttributedString = NSMutableAttributedString(string: claimantNameText, attributes: blackAttributes)
            claimantAttributedString.addAttributes(redAttributes, range: NSRange(location: 15, length: interpreterData.childFullName.count))
            claimantAttributedString.draw(at: CGPoint(x: 50, y: 50))
            
            // Interpreter Name
            let interpreterNameText = "Interpreter Name: \(interpreterData.interpreterFullName)"
            let interpreterAttributedString = NSMutableAttributedString(string: interpreterNameText, attributes: blackAttributes)
            interpreterAttributedString.addAttributes(redAttributes, range: NSRange(location: 18, length: interpreterData.interpreterFullName.count))
            interpreterAttributedString.draw(at: CGPoint(x: 50, y: 70))
            
            // Interpreting Agency
            let agencyText = "Interpreting Agency: \(interpreterData.interpretingAgency)"
            let agencyAttributedString = NSMutableAttributedString(string: agencyText, attributes: blackAttributes)
            agencyAttributedString.addAttributes(redAttributes, range: NSRange(location: 21, length: interpreterData.interpretingAgency.count))
            agencyAttributedString.draw(at: CGPoint(x: 50, y: 90))
            
            // Date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            
            let dateText = "Date: \(dateFormatter.string(from: interpreterData.checkInDate))"
            let timeText = "Time: \(timeFormatter.string(from: interpreterData.checkInDate))"
            
            let dateAttributedString = NSMutableAttributedString(string: dateText, attributes: blackAttributes)
            dateAttributedString.addAttributes(redAttributes, range: NSRange(location: 6, length: dateText.count - 6))
            dateAttributedString.draw(at: CGPoint(x: 50, y: 110))
            
            let timeAttributedString = NSMutableAttributedString(string: timeText, attributes: blackAttributes)
            timeAttributedString.addAttributes(redAttributes, range: NSRange(location: 6, length: timeText.count - 6))
            timeAttributedString.draw(at: CGPoint(x: 50, y: 130))
            
            // Signature section
            "Signature".draw(at: CGPoint(x: 50, y: 160), withAttributes: redAttributes)
            
            // Draw signature if available
            if let signatureImage = interpreterData.signatureImage {
                let signatureRect = CGRect(x: 50, y: 180, width: 300, height: 100)
                signatureImage.draw(in: signatureRect)
            }
        }
        
        // Save PDF to documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("interpreter_checkin_\(interpreterData.interpreterLastName)_\(Date().timeIntervalSince1970).pdf")
            
            do {
                try pdfData.write(to: fileURL)
                print("Interpreter PDF saved to: \(fileURL)")
            } catch {
                print("Error saving interpreter PDF: \(error)")
            }
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
        
        // Clear all interpreter data
        interpreterData.clearData()
        
        // Return to the rotating home screen
        coordinator.popToRoot()
    }
}

#Preview {
    InterpreterConfirmationView()
        .environmentObject(Coordinator())
} 