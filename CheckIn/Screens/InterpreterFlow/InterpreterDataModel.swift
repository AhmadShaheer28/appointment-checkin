//
//  InterpreterDataModel.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import UIKit

// Shared data model for interpreter check-in flow
class InterpreterDataModel: ObservableObject {
    @Published var childFirstName = ""
    @Published var childLastName = ""
    @Published var interpreterFirstName = ""
    @Published var interpreterLastName = ""
    @Published var interpretingAgency = ""
    @Published var language = ""
    @Published var signatureImage: UIImage?
    @Published var checkInDate = Date()
    
    static let shared = InterpreterDataModel()
    private init() {}
    
    // Computed properties for convenience
    var childFullName: String {
        return "\(childFirstName) \(childLastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var interpreterFullName: String {
        return "\(interpreterFirstName) \(interpreterLastName)".trimmingCharacters(in: .whitespaces)
    }
    
    // Validation
    var isFormComplete: Bool {
        return !childFirstName.isEmpty &&
               !childLastName.isEmpty &&
               !interpreterFirstName.isEmpty &&
               !interpreterLastName.isEmpty &&
               !interpretingAgency.isEmpty &&
               !language.isEmpty &&
               signatureImage != nil
    }
    
    // Generate PDF data for interpreter check-in
    func generatePDFData() -> Data? {
        guard signatureImage != nil else { return nil }
        
        // Create PDF document (standard letter size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        return pdfRenderer.pdfData { context in
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
            let claimantNameText = "Claimant Name: \(childFullName)"
            let claimantAttributedString = NSMutableAttributedString(string: claimantNameText, attributes: blackAttributes)
            claimantAttributedString.addAttributes(redAttributes, range: NSRange(location: 15, length: childFullName.count))
            claimantAttributedString.draw(at: CGPoint(x: 50, y: 50))
            
            // Interpreter Name
            let interpreterNameText = "Interpreter Name: \(interpreterFullName)"
            let interpreterAttributedString = NSMutableAttributedString(string: interpreterNameText, attributes: blackAttributes)
            interpreterAttributedString.addAttributes(redAttributes, range: NSRange(location: 18, length: interpreterFullName.count))
            interpreterAttributedString.draw(at: CGPoint(x: 50, y: 70))
            
            // Interpreting Agency
            let agencyText = "Interpreting Agency: \(interpretingAgency)"
            let agencyAttributedString = NSMutableAttributedString(string: agencyText, attributes: blackAttributes)
            agencyAttributedString.addAttributes(redAttributes, range: NSRange(location: 21, length: interpretingAgency.count))
            agencyAttributedString.draw(at: CGPoint(x: 50, y: 90))
            
            // Language
            let languageText = "Language: \(language)"
            let languageAttributedString = NSMutableAttributedString(string: languageText, attributes: blackAttributes)
            languageAttributedString.addAttributes(redAttributes, range: NSRange(location: 10, length: language.count))
            languageAttributedString.draw(at: CGPoint(x: 50, y: 110))
            
            // Date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            
            let dateText = "Date: \(dateFormatter.string(from: checkInDate))"
            let timeText = "Time: \(timeFormatter.string(from: checkInDate))"
            
            let dateAttributedString = NSMutableAttributedString(string: dateText, attributes: blackAttributes)
            dateAttributedString.addAttributes(redAttributes, range: NSRange(location: 6, length: dateText.count - 6))
            dateAttributedString.draw(at: CGPoint(x: 50, y: 130))
            
            let timeAttributedString = NSMutableAttributedString(string: timeText, attributes: blackAttributes)
            timeAttributedString.addAttributes(redAttributes, range: NSRange(location: 6, length: timeText.count - 6))
            timeAttributedString.draw(at: CGPoint(x: 50, y: 150))
            
            // Signature section
            "Signature".draw(at: CGPoint(x: 50, y: 180), withAttributes: redAttributes)
            
            // Draw signature if available
            if let signatureImage = signatureImage {
                let signatureRect = CGRect(x: 50, y: 200, width: 300, height: 100)
                signatureImage.draw(in: signatureRect)
            }
        }
    }
    
    // Upload PDF to Google Drive
    func uploadToGoogleDrive() {
        guard let pdfData = generatePDFData() else {
            print("❌ Failed to generate PDF data for interpreter")
            return
        }
        
        GoogleDriveManager.shared.uploadInBackground {
            try await GoogleDriveManager.shared.uploadInterpreterPDF(
                interpreterFirstName: self.interpreterFirstName,
                interpreterLastName: self.interpreterLastName,
                pdfData: pdfData,
                date: self.checkInDate
            )
        }
    }
    
    // Clear all data when flow is complete
    func clearData() {
        childFirstName = ""
        childLastName = ""
        interpreterFirstName = ""
        interpreterLastName = ""
        interpretingAgency = ""
        language = ""
        signatureImage = nil
        checkInDate = Date()
    }
} 
