//
//  InterpreterFormSignatureView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI

struct InterpreterFormSignatureView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var interpreterData = InterpreterDataModel.shared
    @FocusState private var focusedField: Field?
    @State private var signaturePaths: [Path] = []
    @State private var currentPath = Path()
    @State private var isSigning = false
    @State private var hasSignature = false
    
    enum Field: CaseIterable {
        case childFirstName, childLastName, interpreterFirstName, interpreterLastName, interpretingAgency, language
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Responsive sizing adjusted for better fit
            let logoSize = min(screenWidth, screenHeight) * 0.12
            let textFieldWidth = screenWidth * 0.35
            let textFieldHeight = screenHeight * 0.06
            let fontSize = screenHeight * 0.022
            let buttonFontSize = screenHeight * 0.025
            let spacing = screenHeight * 0.02
            let signatureBoxWidth = screenWidth * 0.8
            let signatureBoxHeight = screenHeight * 0.15
            
            ZStack {
                Color("light_beige")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: spacing) {
                        // Logo at top
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: logoSize, height: logoSize)
                            .padding(.top, screenHeight * 0.01)
                        
                        // Text fields in 3x2 grid
                        VStack(spacing: spacing) {
                            // First row - Child names
                            HStack(spacing: screenWidth * 0.1) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.childFirstName)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.childFirstName)
                                        .focused($focusedField, equals: .childFirstName)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .childFirstName
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.childLastName)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.childLastName)
                                        .focused($focusedField, equals: .childLastName)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .childLastName
                                        }
                                }
                            }
                            
                            // Second row - Interpreter names
                            HStack(spacing: screenWidth * 0.1) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.interpreterFirstName)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.interpreterFirstName)
                                        .focused($focusedField, equals: .interpreterFirstName)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .interpreterFirstName
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.interpreterLastName)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.interpreterLastName)
                                        .focused($focusedField, equals: .interpreterLastName)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .interpreterLastName
                                        }
                                }
                            }
                            
                            // Third row - Agency and Language
                            HStack(spacing: screenWidth * 0.1) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.interpretingAgency)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.interpretingAgency)
                                        .focused($focusedField, equals: .interpretingAgency)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .interpretingAgency
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(String.language)
                                        .font(.custom("Roboto-Medium", size: fontSize))
                                        .foregroundColor(Color("primary_blue"))
                                    
                                    TextField("", text: $interpreterData.language)
                                        .focused($focusedField, equals: .language)
                                        .font(.custom("Roboto-Regular", size: fontSize))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(width: textFieldWidth, height: textFieldHeight)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            focusedField = .language
                                        }
                                    
                                }
                            }
                        }
                        
                        // Sign Below text
                        Text(String.signBelow)
                            .font(.custom("Roboto-Medium", size: fontSize))
                            .foregroundColor(Color("primary_blue"))
                            .multilineTextAlignment(.center)
                            .padding(.top, spacing * 0.5)
                        
                        // Signature box
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: signatureBoxWidth, height: signatureBoxHeight)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                }
                            
                            // Signature canvas
                            Canvas { context, size in
                                context.stroke(
                                    Path { path in
                                        for signaturePath in signaturePaths {
                                            path.addPath(signaturePath)
                                        }
                                        path.addPath(currentPath)
                                    },
                                    with: .color(Color("primary_blue")),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                                )
                            }
                            .frame(width: signatureBoxWidth, height: signatureBoxHeight)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if !isSigning {
                                            currentPath = Path()
                                            currentPath.move(to: value.location)
                                            isSigning = true
                                        } else {
                                            currentPath.addLine(to: value.location)
                                        }
                                    }
                                    .onEnded { _ in
                                        signaturePaths.append(currentPath)
                                        currentPath = Path()
                                        isSigning = false
                                        hasSignature = !signaturePaths.isEmpty
                                        saveSignatureToDataModel()
                                    }
                            )
                            
                            // Show message if no signature
                            if signaturePaths.isEmpty && !isSigning {
                                Text("Sign here with your finger")
                                    .font(.custom("Roboto-Regular", size: fontSize * 0.7))
                                    .foregroundColor(.gray)
                                    .allowsHitTesting(false)
                            }
                        }
                        .cornerRadius(8)
                        
                        // Continue button (disabled until all fields filled & signed)
                        Button(action: {
                            IdleTimerManager.shared.userDidInteract() // Reset idle timer on button tap
                            coordinator.push(.interpreterConfirmation)
                        }) {
                            Text(String.continueButton)
                                .font(.custom("Roboto-Medium", size: buttonFontSize))
                                .foregroundColor(.white)
                                .padding(.horizontal, screenWidth * 0.1)
                                .padding(.vertical, screenHeight * 0.02)
                                .frame(maxWidth: screenWidth * 0.6)
                                .background(interpreterData.isFormComplete ? Color("primary_blue") : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!interpreterData.isFormComplete)
                        .padding(.bottom, screenHeight * 0.02)
                    }
                    .padding(.bottom, 20) // Ensure some bottom padding for the ScrollView
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            // Auto-focus first field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .childFirstName
            }
        }
    }
    
    private func saveSignatureToDataModel() {
        let signatureBoxWidth: CGFloat = 600
        let signatureBoxHeight: CGFloat = 200
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: signatureBoxWidth, height: signatureBoxHeight))
        
        let signatureImage = renderer.image { context in
            // Fill with white background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: signatureBoxWidth, height: signatureBoxHeight))
            
            // Draw signature paths
            context.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            for path in signaturePaths {
                context.cgContext.addPath(path.cgPath)
                context.cgContext.strokePath()
            }
        }
        
        interpreterData.signatureImage = signatureImage
    }
}

#Preview {
    InterpreterFormSignatureView()
        .environmentObject(Coordinator())
} 
