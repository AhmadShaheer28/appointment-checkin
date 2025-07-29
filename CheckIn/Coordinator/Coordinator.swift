//
//  Coordinator.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import SwiftUI


enum Page: Hashable {
    case authentication
    case homeRotation
    case menu
    case appointmentTextEntry
    case appointmentSignature
    case appointmentPhotoInstruction
    case appointmentCamera
    case appointmentPhotoVerification
    case appointmentConfirmation
    case interpreterFormSignature
    case interpreterConfirmation
}


class Coordinator: ObservableObject {
    @Published var path = [Page]()

    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop(page: Page? = nil) {
        if let page = page {
            path.removeAll { $0 == page }
            
        } else {
            if path.isNotEmpty {
                path.removeLast()
            }
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .authentication:
            AuthenticationView()
        case .homeRotation:
            HomeRotationView()
        case .menu:
            MenuView()
        case .appointmentTextEntry:
            AppointmentTextEntryView()
        case .appointmentSignature:
            AppointmentSignatureView()
        case .appointmentPhotoInstruction:
            AppointmentPhotoInstructionView()
        case .appointmentCamera:
            AppointmentCameraView()
        case .appointmentPhotoVerification:
            AppointmentPhotoVerificationView()
        case .appointmentConfirmation:
            AppointmentConfirmationView()
        case .interpreterFormSignature:
            InterpreterFormSignatureView()
        case .interpreterConfirmation:
            InterpreterConfirmationView()
        }
        
    }
    
}
