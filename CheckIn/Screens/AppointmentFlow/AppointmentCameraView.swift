//
//  AppointmentCameraView.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct AppointmentCameraView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var camera = CameraModel()
    @StateObject private var appointmentData = AppointmentDataModel.shared
    @State private var countdown = 5
    @State private var showCountdown = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                // Camera preview
                CameraPreview(camera: camera)
                    .ignoresSafeArea()
                
                // Overlay with countdown
                if showCountdown {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        Text("\(countdown)")
                            .font(.system(size: screenHeight * 0.2, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(countdown > 0 ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 0.5), value: countdown)
                    }
                }
                
                // Instructions at top
                if !showCountdown {
                    VStack {
                        Text("Position yourself with your ID")
                            .font(.custom("Roboto-Medium", size: screenHeight * 0.025))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.top, screenHeight * 0.05)
                        
                        Spacer()
                        
                        // Start countdown button
                        Button(action: {
                            IdleTimerManager.shared.userDidInteract()
                            startCountdown()
                        }) {
                            Text("Start Photo Countdown")
                                .font(.custom("Roboto-Medium", size: screenHeight * 0.03))
                                .foregroundColor(.white)
                                .padding(.horizontal, screenWidth * 0.08)
                                .padding(.vertical, screenHeight * 0.02)
                                .background(Color("primary_blue"))
                                .cornerRadius(12)
                        }
                        .padding(.bottom, screenHeight * 0.08)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .idleTimer()
        .onAppear {
            countdown = 5
            showCountdown = false
            // Clear any previous photo when entering camera
            appointmentData.capturedPhoto = nil
            camera.checkPermissions()
            camera.setupCameraIfNeeded()
        }
        .onDisappear {
            // Don't stop camera when navigating away - just pause
            camera.pauseSession()
        }
        .onChange(of: appointmentData.capturedPhoto) { image in
            if image != nil {
                // Navigate to photo verification with captured image
                coordinator.push(.appointmentPhotoVerification)
            }
        }
    }
    
    private func startCountdown() {
        showCountdown = true
        countdown = 5
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                // Capture the photo
                camera.capturePhoto { image in
                    appointmentData.capturedPhoto = image
                }
                showCountdown = false
            }
        }
    }
}

// Camera Model for handling camera operations
class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var output = AVCapturePhotoOutput()
    @Published var isCameraSetup = false
    @Published var isSessionRunning = false
    
    private var captureCompletion: ((UIImage?) -> Void)?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func setupCameraIfNeeded() {
        if !isCameraSetup {
            setupCamera()
        } else {
            resumeSession()
        }
    }
    
    func setupCamera() {
        guard !isCameraSetup else { return }
        
        do {
            session.beginConfiguration()
            
            // Use front camera
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                session.commitConfiguration() // Important: commit before returning
                print("Front camera not available")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: frontCamera)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.preview = AVCaptureVideoPreviewLayer(session: self.session)
                self.preview.videoGravity = .resizeAspectFill
                self.isCameraSetup = true
            }
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
            
        } catch {
            session.commitConfiguration() // Important: commit before handling error
            print("Camera setup error: \(error)")
        }
    }
    
    func resumeSession() {
        guard isCameraSetup && !isSessionRunning else { return }
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = true
            }
        }
    }
    
    func pauseSession() {
        guard isSessionRunning else { return }
        
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        
        captureCompletion?(image)
    }
}

// Camera Preview UIViewRepresentable
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if camera.isCameraSetup && camera.preview.superlayer == nil {
            camera.preview.frame = uiView.bounds
            uiView.layer.addSublayer(camera.preview)
        }
    }
}

#Preview {
    AppointmentCameraView()
        .environmentObject(Coordinator())
} 
