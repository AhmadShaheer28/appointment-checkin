//
//  AppointmentDataModel.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import UIKit

// Shared data model for appointment check-in flow
class AppointmentDataModel: ObservableObject {
    @Published var caregiverFirstName = ""
    @Published var caregiverLastName = ""
    @Published var childFirstName = ""
    @Published var childLastName = ""
    @Published var signatureImage: UIImage?
    @Published var capturedPhoto: UIImage?
    @Published var checkInDate = Date()
    
    static let shared = AppointmentDataModel()
    private init() {}
    
    // Computed properties for convenience
    var caregiverFullName: String {
        return "\(caregiverFirstName) \(caregiverLastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var childFullName: String {
        return "\(childFirstName) \(childLastName)".trimmingCharacters(in: .whitespaces)
    }
    
    // Generate PDF data for appointment check-in
    func generatePDFData() -> Data? {
        guard let image = capturedPhoto else { return nil }
        
        // Create PDF document (standard letter size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        return pdfRenderer.pdfData { context in
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
            let caregiverNameText = "Caregiver Name: \(caregiverFullName)"
            let caregiverAttributedString = NSMutableAttributedString(string: caregiverNameText, attributes: nameAttributes)
            caregiverAttributedString.addAttributes(redAttributes, range: NSRange(location: 16, length: caregiverFullName.count))
            caregiverAttributedString.draw(at: CGPoint(x: 50, y: 70))
            
            // Claimant Name  
            let claimantNameText = "Claimant Name: \(childFullName)"
            let claimantAttributedString = NSMutableAttributedString(string: claimantNameText, attributes: nameAttributes)
            claimantAttributedString.addAttributes(redAttributes, range: NSRange(location: 15, length: childFullName.count))
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
            if let signatureImage = signatureImage {
                let signatureRect = CGRect(x: 50, y: 360, width: 200, height: 80)
                signatureImage.draw(in: signatureRect)
            }
            
            // Date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            
            let dateText = "Date: \(dateFormatter.string(from: checkInDate))"
            let timeText = "Time: \(timeFormatter.string(from: checkInDate))"
            
            dateText.draw(at: CGPoint(x: 50, y: 460), withAttributes: redAttributes)
            timeText.draw(at: CGPoint(x: 50, y: 480), withAttributes: redAttributes)
            
            // Draw the captured photo
            let imageRect = CGRect(x: 50, y: 520, width: 200, height: 300)
            image.draw(in: imageRect)
        }
    }
    
    // Upload PDF to Google Drive
    func uploadToGoogleDrive() {
        guard let pdfData = generatePDFData() else {
            print("❌ Failed to generate PDF data for appointment")
            return
        }
        
        GoogleDriveManager.shared.uploadInBackground {
            try await GoogleDriveManager.shared.uploadAppointmentPDF(
                caregiverFirstName: self.caregiverFirstName,
                caregiverLastName: self.caregiverLastName,
                childFirstName: self.childFirstName,
                childLastName: self.childLastName,
                pdfData: pdfData,
                date: self.checkInDate
            )
        }
    }
    
    // Clear all data when flow is complete
    func clearData() {
        caregiverFirstName = ""
        caregiverLastName = ""
        childFirstName = ""
        childLastName = ""
        signatureImage = nil
        capturedPhoto = nil
        checkInDate = Date()
    }
} 
