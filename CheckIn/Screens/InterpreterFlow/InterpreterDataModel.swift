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