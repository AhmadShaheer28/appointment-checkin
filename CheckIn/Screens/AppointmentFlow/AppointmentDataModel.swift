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