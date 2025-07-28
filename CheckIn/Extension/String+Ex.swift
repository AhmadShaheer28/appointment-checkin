//
//  String+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 21/08/2024.
//

import Foundation
@preconcurrency import AVFoundation
import UIKit
import SwiftUICore


enum DateFormat: String, CaseIterable {
    case fullDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case fullDateTime = "yyyy-MM-dd'T'HH:mm:ss"
    case shortDateFormat = "MM-dd-yyyy"
    case dd_mm_yyyy = "dd-MM-yyyy"
    case yyyy_mm_dd = "yyyy-MM-dd"
    case eeee_mmm_dd = "EEEE, MMM dd"
    case eeee_mmm_dd_yyyy = "EEEE, MMM dd, yyyy"
    case mmmm_dd_yyyy = "MMMM dd, yyyy"
    case dd_mmmm_yyyy = "dd MMMM, yyyy"
    case hh_mm = "HH:mm"
    case dd_mmm = "dd MMM"
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var isEmptyOrWhitespaces: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func convertDateFormat(from inputFormat: DateFormat, to outputFormat: DateFormat) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat.rawValue
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC input

        guard let date = inputFormatter.date(from: self) else {
            return nil
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat.rawValue
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.timeZone = TimeZone.current // ⬅️ Local timezone

        return outputFormatter.string(from: date)
    }
    
    func toDate(_ dateFormat: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    func formatIfToday(using format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale.current
        
        guard let inputDate = self.toDate else {
            return self
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(inputDate) {
            return "Today"
        } else {
            return formatter.string(from: inputDate)
        }
    }
    
    var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set to UTC
        
        for format in DateFormat.allCases {
            dateFormatter.dateFormat = format.rawValue
            if let date = dateFormatter.date(from: self) {
                return date
            }
        }
        return nil
    }
    
    func hasDatePassed(_ dateFormat: DateFormat) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let dateToCompare = dateFormatter.date(from: self) {
            let currentDate = Date()
            return currentDate > dateToCompare
        } else {
            debugPrint("Invalid date string")
            return false
        }
    }
    
    func generateThumbnail() async throws -> UIImage? {
        return try await withCheckedThrowingContinuation { continuation in
            if let url = URL(string: self.removingPercentEncoding ?? "") {
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.requestedTimeToleranceAfter = .zero
                imageGenerator.requestedTimeToleranceBefore = .zero
                
                let time = CMTime(seconds: 0.6, preferredTimescale: 600)
                
                DispatchQueue.global().async {
                    do {
                        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let uiImage = UIImage(cgImage: cgImage)
                        
                        DispatchQueue.main.async {
                            continuation.resume(returning: uiImage)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    func getSize() -> CGFloat {
        if let font = UIFont.init(name: FontStyle.medium.name, size: 11) {
            let attributes = [NSAttributedString.Key.font: font]
            let size = (self as NSString).size(withAttributes: attributes)
            return size.width
        }
        
        return 0
    }
    
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isLocalFileUrl() -> Bool {
        return self.contains("file://")
    }
    
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func loadImage() async -> UIImage? {
        guard let url = URL(string: self) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Image loading failed:", error)
            return nil
        }
    }

}


// MARK: - Localized Strings for CheckIn App
extension String {
    // Slide Titles
    static let interpreter = "Interpreter"
    static let evaluationAppointment = "Evaluation\nAppointment"
    
    // Button Labels
    static let checkInHere = "Check-In Here"
    static let appointmentCheckIn = "Appointment Check-In"
    static let interpreterCheckIn = "Interpreter Check-In"
    
    // Team Label
    static let aTeam = "A-TEAM"
    
    // Appointment Check-In Flow
    static let caregiverFirstName = "Caregiver First Name"
    static let caregiverLastName = "Caregiver Last Name"
    static let childFirstName = "Child First Name"
    static let childLastName = "Child Last Name"
    static let continueButton = "Continue"
    
    // Signature Screen
    static let pleaseSignBelow = "Please Sign Below"
    
    // Photo Instructions
    static let photoInstructionTitle = "Please find your photo ID and hold it up to the camera. Make sure your face and your ID can both be seen as in the picture below."
    static let photoInstructionSubtitle = "When you press the \"Take Photo\" button, a countdown will start, then your picture will be taken after 5 seconds."
    static let takePhoto = "Take Photo"
    
    // Photo Verification
    static let photoVerificationQuestion = "Can you see both your face and your ID card clearly in the photo below?"
    static let acceptPhoto = "Accept Photo"
    static let retakePhoto = "Retake Photo"
    
    // Confirmation
    static let thankYouMessage = "Thank you for checking in. Your evaluator has been informed and will come to meet you at your scheduled time. Please have a seat in the lobby while you wait."
    static let finishCheckIn = "Finish Check-In"
    
    // Evaluation Information
    static let evaluationDisclaimer = "I understand that today's evaluation is not a general health exam. Our specialists cannot discuss, give opinions, or recommend treatments based on today's results. The specialist you see today does not decide your disability status. That decision is made by the agency that referred you. For questions about this evaluation, please contact the analyst handling your case. Your analyst's contact information is located on the letter you received informing you of this appointment."
}


extension Double {
    func toTimeString() -> String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
