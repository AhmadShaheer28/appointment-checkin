//
//  AppointmentTextEntryView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct AppointmentTextEntryView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var appointmentData = AppointmentDataModel.shared
    @FocusState private var focusedField: Field?
    
    enum Field: CaseIterable {
        case caregiverFirstName, caregiverLastName, childFirstName, childLastName
    }
    
    // Computed property to check if all required fields are filled
    private var isFormValid: Bool {
        !appointmentData.caregiverFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !appointmentData.caregiverLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !appointmentData.childFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !appointmentData.childLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing
            let textFieldWidth = screenWidth * 0.35
            let textFieldHeight = screenHeight * 0.08
            let fontSize = screenHeight * 0.025
            let buttonFontSize = screenHeight * 0.03
            let spacing = screenHeight * 0.04
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                VStack(spacing: spacing) {
                    // Logo at top
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.4)
                        .padding(.top, screenHeight * 0.05)
                    
                    
                    // Text fields in 2x2 grid
                    VStack(spacing: spacing) {
                        // First row - Caregiver names
                        HStack(spacing: screenWidth * 0.1) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String.caregiverFirstName)
                                    .font(.custom("Roboto-Medium", size: fontSize))
                                    .foregroundColor(Color("primary_blue"))
                                
                                TextField("", text: $appointmentData.caregiverFirstName)
                                    .focused($focusedField, equals: .caregiverFirstName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.custom("Roboto-Regular", size: fontSize))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: textFieldWidth, height: textFieldHeight)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String.caregiverLastName)
                                    .font(.custom("Roboto-Medium", size: fontSize))
                                    .foregroundColor(Color("primary_blue"))
                                
                                TextField("", text: $appointmentData.caregiverLastName)
                                    .focused($focusedField, equals: .caregiverLastName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.custom("Roboto-Regular", size: fontSize))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: textFieldWidth, height: textFieldHeight)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Second row - Child names
                        HStack(spacing: screenWidth * 0.1) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String.childFirstName)
                                    .font(.custom("Roboto-Medium", size: fontSize))
                                    .foregroundColor(Color("primary_blue"))
                                
                                TextField("", text: $appointmentData.childFirstName)
                                    .focused($focusedField, equals: .childFirstName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.custom("Roboto-Regular", size: fontSize))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: textFieldWidth, height: textFieldHeight)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String.childLastName)
                                    .font(.custom("Roboto-Medium", size: fontSize))
                                    .foregroundColor(Color("primary_blue"))
                                
                                TextField("", text: $appointmentData.childLastName)
                                    .focused($focusedField, equals: .childLastName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.custom("Roboto-Regular", size: fontSize))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: textFieldWidth, height: textFieldHeight)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                        coordinator.push(.appointmentSignature)
                    }) {
                        Text(String.continueButton)
                            .font(.custom("Roboto-Medium", size: buttonFontSize))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenWidth * 0.1)
                            .padding(.vertical, screenHeight * 0.02)
                            .frame(maxWidth: screenWidth * 0.6)
                            .background(isFormValid ? Color("primary_blue") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.bottom, screenHeight * 0.08)
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            // Auto-focus first field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focusedField = .caregiverFirstName
            }
        }
    }
}

#Preview {
    AppointmentTextEntryView()
        .environmentObject(Coordinator())
} 
