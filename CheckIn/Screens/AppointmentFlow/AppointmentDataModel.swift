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

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return pdfRenderer.pdfData { context in
            context.beginPage()
            var currentY: CGFloat = margin

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            "Check-In Photo Verification".draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
            currentY += 40

            // Name Attributes
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]

            // Red Text Attributes (used for emphasis)
            let redAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.systemRed
            ]

            // Caregiver Name
            let caregiverText = "Caregiver Name: \(caregiverFullName)"
            let caregiverAttr = NSMutableAttributedString(string: caregiverText, attributes: textAttributes)
            caregiverAttr.addAttributes(redAttributes, range: NSRange(location: 16, length: caregiverFullName.count))
            caregiverAttr.draw(at: CGPoint(x: margin, y: currentY))
            currentY += 20

            // Claimant Name
            let claimantText = "Claimant Name: \(childFullName)"
            let claimantAttr = NSMutableAttributedString(string: claimantText, attributes: textAttributes)
            claimantAttr.addAttributes(redAttributes, range: NSRange(location: 15, length: childFullName.count))
            claimantAttr.draw(at: CGPoint(x: margin, y: currentY))
            currentY += 30

            // Disclaimer
            let disclaimerText = String.evaluationDisclaimer
            let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let disclaimerRect = CGRect(x: margin, y: currentY, width: pageWidth - 2 * margin, height: 100)
            disclaimerText.draw(in: disclaimerRect, withAttributes: disclaimerAttributes)
            currentY += 110

            // Signature Label
            "Signature".draw(at: CGPoint(x: margin, y: currentY), withAttributes: redAttributes)
            currentY += 20

            // Signature Image
            if let signatureImage = signatureImage {
                let sigHeight: CGFloat = 60
                let sigWidth: CGFloat = 200
                let sigRect = CGRect(x: margin, y: currentY, width: sigWidth, height: sigHeight)
                signatureImage.draw(in: sigRect)
                currentY += sigHeight + 10
            }

            // Date & Time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"

            let dateText = "Date: \(dateFormatter.string(from: checkInDate))"
            let timeText = "Time: \(timeFormatter.string(from: checkInDate))"

            dateText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: redAttributes)
            currentY += 20
            timeText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: redAttributes)
            currentY += 30

            // Image: Captured Photo
            let maxImageWidth: CGFloat = pageWidth - 2 * margin
            let maxImageHeight: CGFloat = pageHeight - currentY - 40 // leave bottom margin
            let imageSize = image.size

            let widthRatio = maxImageWidth / imageSize.width
            let heightRatio = maxImageHeight / imageSize.height
            let scale = min(widthRatio, heightRatio)

            let scaledWidth = imageSize.width * scale
            let scaledHeight = imageSize.height * scale

            let x = (pageWidth - scaledWidth) / 2
            let imageRect = CGRect(x: x, y: currentY, width: scaledWidth, height: scaledHeight)
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
